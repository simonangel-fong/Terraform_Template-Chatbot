##############################
# App level
##############################
variable "app_name" {
  description = ""
  default     = "chatbot"
}

variable "app_domain" {
  description = ""
}

variable "app_subdomain_api" {
  description = ""
  default     = "chatbot-api"
}

variable "app_subdomain_web" {
  description = ""
  default     = "chatbot"
}

locals {
  app_api_address = "${var.app_subdomain_api}.${var.app_domain}"
  app_web_address = "${var.app_subdomain_web}.${var.app_domain}"
}

# ########################################
# Cloudflare
# ########################################

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone id"
  type        = string
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
  default     = "chatbot"
}

##############################
# AWS ACM
##############################
variable "aws_cert_arn" {
  description = ""
}
