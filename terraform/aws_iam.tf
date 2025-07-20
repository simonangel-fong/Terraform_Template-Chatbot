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

###############################
# IAM role for API to invoke lambda service
###############################
resource "aws_lambda_permission" "api_gateway_invoke_get" {
  function_name = aws_lambda_function.lambda_function.id
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  statement_id  = "AllowExecutionFromAPIGatewayGET"
  source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*"
}

resource "aws_iam_role_policy" "bedrock_invoke_policy" {
  name = "${var.app_name}-policy-bedrock-invoke"
  role = aws_iam_role.lambda_role.name

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

# ###############################
# # IAM Policy: Lambda CloudWatch Logs
# ###############################
resource "aws_iam_role_policy" "lambda_cloudwatch_logs" {
  name = "${var.app_name}-policy-lambda-cloudwatch-logs"
  role = aws_iam_role.lambda_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "${aws_cloudwatch_log_group.lambda_logs.arn}:*"
        ]
      }
    ]
  })
}

###############################
# IAM Role: API Gateway
###############################
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
}

###############################
# IAM Policy: API Gateway CloudWatch Logs
###############################
resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch_policy" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}





# ###############################
# # IAM role for Agent
# ###############################

# # Agent resource role
# resource "aws_iam_role" "bedrock_agent_role" {
#   name = "bedrock_agent_role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "bedrock.amazonaws.com"
#         }
#         Condition = {
#           StringEquals = {
#             "aws:SourceAccount" = local.account_id
#           }
#           ArnLike = {
#             "aws:SourceArn" = "arn:${local.partition}:bedrock:${local.region}:${local.account_id}:agent/*"
#           }
#         }
#       }
#     ]
#   })
# }

# # Agent role policy
# resource "aws_iam_role_policy" "bedrock_agent_role_policy" {
#   name = "bedrock_agent_role_policy"
#   role = aws_iam_role.bedrock_agent_role.name

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action   = "bedrock:InvokeModel"
#         Effect   = "Allow"
#         Resource = data.aws_bedrock_foundation_model.this.model_arn
#       }
#     ]
#   })
# }
