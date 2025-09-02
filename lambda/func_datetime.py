import datetime
import json


def lambda_handler(event, context):
    now = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")

    response_body = {
        "application/json": {
            "body": {
                "current_datetime": now
            }
        }
    }

    return {
        "messageVersion": "1.0",
        "response": {
            "actionGroup": event["actionGroup"],
            "apiPath": event["apiPath"],
            "httpMethod": event["httpMethod"],
            "httpStatusCode": 200,
            "responseBody": response_body,
        },
        "sessionAttributes": event.get("sessionAttributes", {}),
        "promptSessionAttributes": event.get("promptSessionAttributes", {})
    }
