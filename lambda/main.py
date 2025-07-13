import json
import boto3


def lambda_handler(event, context):
    # if correct
    try:
        response_body = {
            "msg": "hello world"
        }

        # Return proper API Gateway response format
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            },
            'body': json.dumps(response_body)
        }

    # if exception
    except Exception as e:
        # Log the error
        print(f'Error: {str(e)}')

        # Return error response
        error_response = {
            "error": "Internal server error",
            "message": str(e)
        }

        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(error_response)
        }
