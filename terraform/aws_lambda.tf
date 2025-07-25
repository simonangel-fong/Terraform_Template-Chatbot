
data "archive_file" "pack_lambda_main" {
  type        = "zip"
  source_file = "../lambda/main.py"
  output_path = "../lambda/main.zip"
}

resource "aws_lambda_function" "lambda_function" {
  function_name    = "${var.app_name}-lambda-function-chatbot"
  filename         = "../lambda/main.zip"
  role             = aws_iam_role.lambda_role.arn
  handler          = "main.lambda_handler"
  runtime          = var.aws_lambda_function_runtime
  source_code_hash = data.archive_file.pack_lambda_main.output_base64sha256

  timeout = 60 # prevent timeout

  tags = {
    Name        = "${var.app_name}-lambda-function-chatbot"
    Project     = var.app_name
    Environment = "prod"
  }
}
