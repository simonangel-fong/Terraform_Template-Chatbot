##############################
# App level
##############################
variable "app_name" {
  description = "Application name"
  type        = string
  default     = "chatbot"
}

variable "app_domain" {
  description = "Domain name"
  type        = string
}

variable "app_subdomain_web" {
  description = "Subdomain name"
  type        = string
  default     = "chatbot"
}

locals {
  # application web address
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
  type        = string
}

##############################
# AWS ACM
##############################
variable "aws_cert_arn" {
  description = "ACM Certificate arn"
  type        = string
}

##############################
# AWS lambda
##############################
variable "aws_lambda_function_runtime" {
  description = "AWS lambda function runtime"
  type        = string
  default     = "python3.11"
}

##############################
# AWS API Gateway
##############################
variable "aws_apigw_path" {
  description = "API Gateway path"
  type        = string
  default     = "chatbot"
}

variable "aws_bedrock_model" {
  description = "Bedrock model id"
}
