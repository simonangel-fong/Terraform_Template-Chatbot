# ###############################
# API Gateway: List
# ###############################

resource "aws_api_gateway_rest_api" "rest_api" {
  name        = "${var.app_name}-api-gateway"
  description = "${var.app_name} API Gateway"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name        = "${var.app_name}-api-gateway"
    Project     = var.app_name
    Environment = "prod"
  }
}

# /chatbot
resource "aws_api_gateway_resource" "resource_chatbot" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = var.aws_apigw_path
}


# ###############################
# API Gateway Deployment: a snapshot of the REST API configuration
# ###############################
resource "aws_api_gateway_deployment" "rest_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  # Redeploy when any method/integration changes
  triggers = {
    redeployment = sha1(jsonencode([
      # GET /chatbot
      aws_api_gateway_method.method_get_all,
      aws_api_gateway_integration.integration_lambda_get_all,
      aws_api_gateway_method_response.method_response_get_all,
      aws_api_gateway_integration_response.integration_response_get_all,

      # POST /chatbot
      aws_api_gateway_method.method_post_item.id,
      aws_api_gateway_integration.integration_lambda_post_item.id,
      aws_api_gateway_method_response.method_response_post_item.id,
      aws_api_gateway_integration_response.integration_response_post_item.id,

      # OPTIONS /chatbot
      aws_api_gateway_method.method_options_cors.id,
      aws_api_gateway_integration.integration_options_cors.id,
      aws_api_gateway_method_response.method_response_options_cors.id,
      aws_api_gateway_integration_response.integration_response_option_cors.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    # GET /chatbot
    aws_api_gateway_method.method_get_all,
    aws_api_gateway_integration.integration_lambda_get_all,
    aws_api_gateway_method_response.method_response_get_all,
    aws_api_gateway_integration_response.integration_response_get_all,

    # POST /chatbot
    aws_api_gateway_method.method_post_item,
    aws_api_gateway_integration.integration_lambda_post_item,
    aws_api_gateway_method_response.method_response_post_item,
    aws_api_gateway_integration_response.integration_response_post_item,

    # OPTIONS /chatbot
    aws_api_gateway_method.method_options_cors,
    aws_api_gateway_integration.integration_options_cors,
    aws_api_gateway_method_response.method_response_options_cors,
    aws_api_gateway_integration_response.integration_response_option_cors,
  ]
}

###############################
# API Gateway stage
###############################

# account for logging
resource "aws_api_gateway_account" "account_settings" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_role.arn
}

# stage
resource "aws_api_gateway_stage" "api_stage" {
  stage_name    = "prod"
  deployment_id = aws_api_gateway_deployment.rest_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id

  # Enable access logging
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs.arn

    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      caller         = "$context.identity.caller"
      user           = "$context.identity.user"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  xray_tracing_enabled  = true
  cache_cluster_enabled = false

  depends_on = [
    aws_cloudwatch_log_group.api_gateway_logs,
    aws_api_gateway_account.account_settings
  ]
}

