#############################
# lambda role
#############################
resource "aws_iam_role" "lambda_role" {
  name = "${var.app_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}


# ###############################
# IAM role for API to invoke lambda service
# ###############################

resource "aws_lambda_permission" "api_gateway_invoke_get" {
  function_name = aws_lambda_function.lambda_function.id
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  statement_id  = "AllowExecutionFromAPIGatewayGET"
  source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*"
}