# Create a zip file for the Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "src"
  output_path = "dist/lambda_function.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_policy" "lambda_ses_policy" {
  name        = "${var.lambda_function_name}-ses-policy"
  description = "Allow Lambda function to send email using SES"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*" # or specific identity ARN for least privilege
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_ses_permission" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_ses_policy.arn
}

resource "aws_lambda_function" "scheduled_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.11"
  timeout          = 60

  environment {
    variables = {
      ENVIRONMENT = "production"
    }
  }

  tags = {
    Name        = var.lambda_function_name
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

# EventBridge Rule (formerly CloudWatch Events Rule)
resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "${var.lambda_function_name}-schedule"
  description         = "Trigger Lambda function on schedule"
  schedule_expression = "cron(0 9 ? * MON *)" # Every Monday at 9 AM EST?

  # Alternative schedule expressions:
  # "rate(1 hour)"                    - Every hour
  # "rate(1 day)"                     - Every day
  # "cron(0 12 * * ? *)"             - Every day at noon UTC
  # "cron(0 9 ? * MON-FRI *)"        - Weekdays at 9 AM UTC
  # "cron(0/30 * * * ? *)"           - Every 30 minutes
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "LambdaTarget"
  arn       = aws_lambda_function.scheduled_lambda.arn

  # Optional: Pass custom input to the Lambda function
  input = jsonencode({
    source = "scheduled-event"
    detail = "Triggered by EventBridge schedule"
  })
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scheduled_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}

resource "aws_ses_email_identity" "sender" {
  email = "jamesalowenthal@gmail.com"
}
