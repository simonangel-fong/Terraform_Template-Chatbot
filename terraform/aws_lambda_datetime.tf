###############################
# IAM for Lambda: datetime function
###############################

# Assume Role
resource "aws_iam_role" "role_lambda_datetime" {
  name = "${var.app_name}-role-lambda-datetime"

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
    Name        = "${var.app_name}-role-lambda-datetime"
    Environment = "prod"
  }
}

# allow bedrock invoke
resource "aws_lambda_permission" "permission_bedrock_invoke_lambda_datetime" {
  statement_id  = "AllowBedrockInvocation"
  principal     = "bedrock.amazonaws.com"
  source_arn = aws_bedrockagent_agent.bedrock_agent_datetime.agent_arn
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function_datetime.function_name

  depends_on = [
    aws_bedrockagent_agent.bedrock_agent_datetime
  ]
}

###############################
# Lambda Monitor: datetime
###############################
# basic policy: Cloudwatch log group
resource "aws_iam_role_policy_attachment" "lambda_datetime_basic_execution" {
  role       = aws_iam_role.role_lambda_datetime.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# CloudWatch Log Group: datetime
resource "aws_cloudwatch_log_group" "lambda_datetimelogs" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function_datetime.function_name}"
  retention_in_days = 14

  tags = {
    Name        = "${aws_lambda_function.lambda_function_datetime.function_name}-log-group"
    Project     = var.app_name
    Environment = "prod"
  }
}

###############################
# Lambda function: datetime
###############################
# file
data "archive_file" "pack_lambda_datetime" {
  type        = "zip"
  source_file = "../lambda/func_datetime.py"
  output_path = "../lambda/func_datetime.zip"
}

# lambda function: datetime
resource "aws_lambda_function" "lambda_function_datetime" {
  function_name    = "${var.app_name}-lambda-function-datetime"
  handler          = "func_datetime.lambda_handler"
  runtime          = var.aws_lambda_function_runtime
  filename         = "../lambda/func_datetime.zip"
  source_code_hash = data.archive_file.pack_lambda_datetime.output_base64sha256
  role             = aws_iam_role.role_lambda_datetime.arn

  # timeout = 60 # prevent timeout

  tags = {
    Project     = var.app_name
    Name        = "${var.app_name}-lambda-function-datetime"
    Environment = "prod"
  }
}
