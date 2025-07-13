##############################
# App level
##############################
variable "app_name" {
  description = ""
  default     = "ai-agent"
}

variable "app_domain" {
  description = ""
}


##############################
# AWS provider
##############################

variable "aws_region" {
  description = "AWS region"
}

##############################
# AWS lambda
##############################
variable "aws_lambda_function_name" {
  description = "AWS lambda function name"
}

variable "aws_lambda_function_runtime" {
  description = "AWS lambda function runtime"
  default     = "python3.11"
}

##############################
# AWS API Gateway
##############################
variable "aws_apigw_path" {
  description = ""
  default     = "agent"
}
