import boto3
import csv
import datetime
import json
import nyc_city_jobs


def send_email(subject, body):
    client = boto3.client("ses", region_name="us-east-1")
    response = client.send_email(
        Source="jamesalowenthal@gmail.com",
        Destination={"ToAddresses": ["jamesalowenthal@gmail.com"]},
        Message={"Subject": {"Data": subject}, "Body": {"Html": {"Data": body}}},
    )
    return response


def lambda_handler(event, context):
    current_time = datetime.datetime.now().isoformat()
    html_body = nyc_city_jobs.get_nyc_city_jobs()
    current_date = datetime.datetime.now().strftime("%Y-%m-%d")

    send_email(f"NYC City Jobs Update - {current_date}", html_body)

    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "message": "Scheduled Lambda executed successfully",
                "timestamp": current_time,
            }
        ),
    }
