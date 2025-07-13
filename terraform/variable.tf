variable "aws_region" {
  description = "AWS region"
}

variable "aws_lambda_function_name" {
  description = "AWS lambda function name"
}

variable "aws_lambda_function_runtime" {
  description = "AWS lambda function runtime"
  default = "python3.11"
}