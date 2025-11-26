variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  default     = "nyc-city-jobs-lambda"
}

variable "sender_email" {
  description = "Email address of the sender"
}

variable "destination_emails" {
  description = "Email addresses of the recipients"
  type        = list(string)
}
