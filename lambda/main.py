import json
import boto3
import logging
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):

    cors_headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
        'Access-Control-Allow-Methods': 'POST,OPTIONS'
    }

    try:
        # Check HTTP method - only allow POST
        http_method = event.get('httpMethod', '').upper()

        if http_method == 'OPTIONS':
            # Handle preflight CORS request
            return {
                'statusCode': 200,
                'headers': cors_headers,
                'body': ''
            }

        if http_method != 'POST':
            logger.warning(f"Method not allowed: {http_method}")
            return {
                'statusCode': 405,
                'headers': cors_headers,
                'body': json.dumps({
                    'success': False,
                    'error': 'MethodNotAllowed',
                    'message': f'HTTP method {http_method} not allowed. Only POST requests are supported.'
                })
            }

        # Parse request body
        if not event.get('body'):
            logger.error("Missing request body")
            return {
                'statusCode': 400,
                'headers': cors_headers,
                'body': json.dumps({
                    'success': False,
                    'error': 'MissingRequestBody',
                    'message': 'Request body is required'
                })
            }

        # Parse JSON body
        if isinstance(event['body'], str):
            body = json.loads(event['body'])
        else:
            body = event['body']

        # Validate user_prompt is present and not empty
        user_prompt = body.get('user_prompt', '').strip()
        if not user_prompt:
            logger.error("Missing or empty user_prompt")
            return {
                'statusCode': 400,
                'headers': cors_headers,
                'body': json.dumps({
                    'success': False,
                    'error': 'MissingUserPrompt',
                    'message': 'user_prompt is required and cannot be empty'
                })
            }

        # Initialize Bedrock client
        client = boto3.client("bedrock-runtime", region_name="ca-central-1")

        # Model ID
        model_id = "anthropic.claude-3-haiku-20240307-v1:0"

        # Prepare request body using the Messages API format
        request_body = {
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 4000,
            "temperature": 0.7,
            "messages": [
                {
                    "role": "user",
                    "content": user_prompt
                }
            ]
        }

        # Invoke the model
        response = client.invoke_model(
            modelId=model_id,
            contentType="application/json",
            accept="application/json",
            body=json.dumps(request_body)
        )

        # Parse response
        response_body = json.loads(response['body'].read())

        # Extract the generated text
        generated_text = response_body.get('content', [{}])[0].get('text', '')

        # Log successful invocation
        logger.info(
            f"Successfully generated response for prompt: {user_prompt[:50]}...")

        # Return successful response
        return {
            'statusCode': 200,
            'headers': cors_headers,
            'body': json.dumps({
                'success': True,
                'generated_text': generated_text,
                'model_used': model_id,
                'input_tokens': response_body.get('usage', {}).get('input_tokens', 0),
                'output_tokens': response_body.get('usage', {}).get('output_tokens', 0)
            })
        }

    except ClientError as e:
        error_code = e.response['Error']['Code']
        error_message = e.response['Error']['Message']

        logger.error(f"AWS ClientError: {error_code} - {error_message}")

        # Map common AWS errors to appropriate HTTP status codes
        status_code = 500
        if error_code == 'ValidationException':
            status_code = 400
        elif error_code == 'AccessDeniedException':
            status_code = 403
        elif error_code == 'ResourceNotFoundException':
            status_code = 404
        elif error_code == 'ThrottlingException':
            status_code = 429

        return {
            'statusCode': status_code,
            'headers': cors_headers,
            'body': json.dumps({
                'success': False,
                'error': error_code,
                'message': error_message
            })
        }

    except json.JSONDecodeError as e:
        logger.error(f"JSON decode error: {str(e)}")
        return {
            'statusCode': 400,
            'headers': cors_headers,
            'body': json.dumps({
                'success': False,
                'error': 'InvalidJSON',
                'message': 'Invalid JSON in request body'
            })
        }

    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': cors_headers,
            'body': json.dumps({
                'success': False,
                'error': 'InternalServerError',
                'message': 'An unexpected error occurred'
            })
        }
