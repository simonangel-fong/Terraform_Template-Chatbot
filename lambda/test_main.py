from main import lambda_handler

if __name__ == "__main__":
    event_prompt = {
        "httpMethod": "POST",
        "headers": {
            "Content-Type": "application/json",
            "User-Agent": "Amazon CloudFront"
        },
        "body": {"user_prompt": "What is robot?"},
        "isBase64Encoded": False,
        "requestContext": {
            "httpMethod": "POST"
        },
        "pathParameters": None,
        "queryStringParameters": None
    }
    context = {}
    print(lambda_handler(event_prompt, context))

    event_none = {}
    print(lambda_handler(event_none, context))
