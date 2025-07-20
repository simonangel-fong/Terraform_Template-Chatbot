# #########################################
# CloudWatch Log Group
# #########################################

# Lambda Function
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
  retention_in_days = 14

  tags = {
    Name        = "${aws_lambda_function.lambda_function.function_name}-log-group"
    Project     = var.app_name
    Environment = "prod"
  }
}

# API Gateway
resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/apigateway/${aws_api_gateway_rest_api.rest_api.name}"
  retention_in_days = 14

  tags = {
    Name        = "${aws_api_gateway_rest_api.rest_api.name}-log-group"
    Project     = var.app_name
    Environment = "prod"
  }
}
