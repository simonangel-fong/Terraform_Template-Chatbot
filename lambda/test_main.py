from main import lambda_handler

if __name__ == "__main__":
    event_prompt = {
        "body": {
            "user_prompt": "What is AI?"
        }
    }
    context = {}
    print(lambda_handler(event_prompt, context))

    event_none = {}
    print(lambda_handler(event_none, context))
