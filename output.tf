output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.scheduled_lambda.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.scheduled_lambda.function_name
}

output "eventbridge_rule_name" {
  description = "Name of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.lambda_schedule.name
}

output "schedule_expression" {
  description = "Schedule expression for the Lambda trigger"
  value       = aws_cloudwatch_event_rule.lambda_schedule.schedule_expression
}
