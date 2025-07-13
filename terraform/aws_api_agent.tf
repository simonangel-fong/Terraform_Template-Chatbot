# ###############################
# API Gateway: get
# ###############################

# method get
resource "aws_api_gateway_method" "method_get_all" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.resource_agent.id
  http_method = "GET"

  authorization = "NONE"
}

# get integrate
resource "aws_api_gateway_integration" "integration_lambda_get_all" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.resource_agent.id
  http_method             = aws_api_gateway_method.method_get_all.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
}

# get response
resource "aws_api_gateway_method_response" "method_response_get_all" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.resource_agent.id
  http_method = aws_api_gateway_method.method_get_all.http_method
  status_code = "200"

  //cors section
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

}

# get integation response
resource "aws_api_gateway_integration_response" "integration_response_get_all" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.resource_agent.id
  http_method = aws_api_gateway_method.method_get_all.http_method
  status_code = aws_api_gateway_method_response.method_response_get_all.status_code


  //cors
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_method.method_get_all,
    aws_api_gateway_integration.integration_lambda_get_all
  ]
}

# ###############################
# API Gateway: post
# ###############################

# method: post
resource "aws_api_gateway_method" "method_post_item" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.resource_agent.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integration 
resource "aws_api_gateway_integration" "integration_lambda_post_item" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.resource_agent.id
  http_method             = aws_api_gateway_method.method_post_item.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
}

# Method Response
resource "aws_api_gateway_method_response" "method_response_post_item" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.resource_agent.id
  http_method = aws_api_gateway_method.method_post_item.http_method
  status_code = "201"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# integration response
resource "aws_api_gateway_integration_response" "integration_response_post_item" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.resource_agent.id
  http_method = aws_api_gateway_method.method_post_item.http_method
  status_code = aws_api_gateway_method_response.method_response_post_item.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_method.method_post_item,
    aws_api_gateway_integration.integration_lambda_post_item
  ]
}

# ###############################
# API Gateway: option cors
# ###############################

# option cors
resource "aws_api_gateway_method" "method_options_cors" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.resource_agent.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# option integration: cors
resource "aws_api_gateway_integration" "integration_options_cors" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.resource_agent.id
  http_method = aws_api_gateway_method.method_options_cors.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# option: method response
resource "aws_api_gateway_method_response" "method_response_options_cors" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.resource_agent.id
  http_method = aws_api_gateway_method.method_options_cors.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# option integration_response
resource "aws_api_gateway_integration_response" "integration_response_option_cors" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.resource_agent.id
  http_method = aws_api_gateway_method.method_options_cors.http_method
  status_code = aws_api_gateway_method_response.method_response_options_cors.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_method.method_options_cors,
    aws_api_gateway_integration.integration_options_cors,
  ]
}