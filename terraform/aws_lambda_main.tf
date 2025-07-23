###############################
# IAM for Lambda: main function
###############################

# Assume Role
resource "aws_iam_role" "role_lambda_main" {
  name = "${var.app_name}-role-lambda-main"

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

  tags = {
    Project     = var.app_name
    Name        = "${var.app_name}-role-lambda-main"
    Environment = "prod"
  }
}


# allow api to invoke lambda main
resource "aws_lambda_permission" "permission_main_api_invoke_lambda" {
  statement_id  = "AllowExecutionFromAPIGatewayGET"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function_main.id
}

# allow lambda main to invoke bedrock
resource "aws_iam_role_policy" "policy_main_lambda_invoke_bedrock" {
  name = "${var.app_name}-policy-lambda-main-invoke-bedrock"
  role = aws_iam_role.role_lambda_main.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ],
        Resource = "*" # Or specify specific model ARNs
      },
      {
        Effect = "Allow",
        Action = [
          "bedrock:GetFoundationModel"
        ],
        Resource = "*"
      }
    ]
  })
}

###############################
# Lambda Monitor: main
###############################
# basic policy: Cloudwatch log group
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.role_lambda_main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# CloudWatch Log Group: mail
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function_main.function_name}"
  retention_in_days = 14

  tags = {
    Name        = "${aws_lambda_function.lambda_function_main.function_name}-log-group"
    Project     = var.app_name
    Environment = "prod"
  }
}


###############################
# Lambda function: main
###############################
# file
data "archive_file" "pack_lambda_main" {
  type        = "zip"
  source_file = "../lambda/main.py"
  output_path = "../lambda/main.zip"
}

# lambda function: main
resource "aws_lambda_function" "lambda_function_main" {
  function_name    = "${var.app_name}-lambda-function-main"
  handler          = "main.lambda_handler"
  runtime          = var.aws_lambda_function_runtime
  filename         = "../lambda/main.zip"
  source_code_hash = data.archive_file.pack_lambda_main.output_base64sha256
  role             = aws_iam_role.role_lambda_main.arn

  timeout = 60 # prevent timeout

  tags = {
    Project     = var.app_name
    Name        = "${var.app_name}-lambda-function-main"
    Environment = "prod"
  }
}
