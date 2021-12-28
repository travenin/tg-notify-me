import boto3
import http.client
import json
import json
import os
from http import HTTPStatus


# Secrets cache
secrets = None


def get_secret_value(key: str) -> str:
    global secrets

    if not secrets:
        secret_id = os.getenv("SECRET_ID")
        secrets_manager = boto3.client("secretsmanager")
        secrets = json.loads(
            secrets_manager.get_secret_value(SecretId=secret_id)["SecretString"]
        )

    return secrets[key]


def send_message(message: str):
    tg_token = get_secret_value("tg_token")
    chat_id = get_secret_value("chat_id")

    tg_api_host = os.getenv("TELEGRAM_API_HOST")
    endpoint = f"/bot{tg_token}/sendMessage"
    headers = {"content-type": "application/json"}
    payload = {"chat_id": chat_id, "text": message}

    connection = http.client.HTTPSConnection(tg_api_host)
    connection.request(
        "POST",
        endpoint,
        json.dumps(payload),
        headers,
    )

    response = connection.getresponse()
    response_obj = json.loads(response.read())
    print(response.status, response_obj)

    return {
        "status": response.status,
        "response": response_obj,
    }


def handler(event, context):
    try:
        message = json.loads(event["body"])["message"]
    except KeyError:
        return {
            "statusCode": HTTPStatus.BAD_REQUEST,
            "body": json.dumps({"message": "Bad request, missing message"}),
        }
    except Exception as e:
        raise e

    print("Message:", message)

    # Send the message to Telegram
    response = send_message(message)

    return {
        "statusCode": response["status"],
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"response": response["response"]}),
    }
