import datetime
import json

import nyc_city_jobs


def lambda_handler(event, context):
    current_time = datetime.datetime.now().isoformat()
    nyc_city_jobs.main()

    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "message": "Scheduled Lambda executed successfully",
                "timestamp": current_time,
            }
        ),
    }
