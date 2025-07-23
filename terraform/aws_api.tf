###############################
# IAM for API Gateway
###############################

# Assume Role
resource "aws_iam_role" "api_gateway_role" {
  name = "${var.app_name}-api-gateway-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Project     = var.app_name
    Name        = "${var.app_name}-api-gateway-role"
    Environment = "prod"
  }
}

# allow cloudwatch log
resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch_policy" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# cloudwatc log group
resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/apigateway/${aws_api_gateway_rest_api.rest_api.name}"
  retention_in_days = 14

  tags = {
    Project     = var.app_name
    Name        = "${aws_api_gateway_rest_api.rest_api.name}-log-group"
    Environment = "prod"
  }
}

# ###############################
# API Gateway
# ###############################

resource "aws_api_gateway_rest_api" "rest_api" {
  name        = "${var.app_name}-api-gateway"
  description = "${var.app_name} API Gateway"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Project     = var.app_name
    Name        = "${var.app_name}-api-gateway"
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
      aws_api_gateway_method.method_post_item,
      aws_api_gateway_integration.integration_lambda_post_item,
      aws_api_gateway_method_response.method_response_post_item,
      aws_api_gateway_integration_response.integration_response_post_item,

      # OPTIONS /chatbot
      aws_api_gateway_method.method_options_cors,
      aws_api_gateway_integration.integration_options_cors,
      aws_api_gateway_method_response.method_response_options_cors,
      aws_api_gateway_integration_response.integration_response_option_cors,
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
