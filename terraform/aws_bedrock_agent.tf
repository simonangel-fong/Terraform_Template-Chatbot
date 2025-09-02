##############################
# IAM Role: for agent
##############################

# agent role
resource "aws_iam_role" "role_bedrock_agent" {
  name = "${var.app_name}-role-bedrock-agent"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = {
    Project     = var.app_name
    Name        = "${var.app_name}-role-bedrock-agent"
    Environment = "prod"
  }
}

# role inline policy
resource "aws_iam_role_policy" "role_policy_agent" {
  name = "${var.app_name}-role-policy-agent"
  role = aws_iam_role.role_bedrock_agent.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = "${aws_lambda_function.lambda_function_datetime.arn}"
      },
      {
        Sid    = "AmazonBedrockAgentBedrockFoundationModelPolicyProd"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = [
          "arn:aws:bedrock:${var.aws_region}::foundation-model/anthropic.claude-3-haiku-20240307-v1:0",
          "arn:aws:bedrock:${var.aws_region}::foundation-model/anthropic.claude-3-sonnet-20240229-v1:0",
          "arn:aws:bedrock:${var.aws_region}::foundation-model/anthropic.claude-3-5-sonnet-20241022-v2:0",
          "arn:aws:bedrock:${var.aws_region}::foundation-model/amazon.nova-lite-v1:0",
          "arn:aws:bedrock:${var.aws_region}::foundation-model/amazon.nova-micro-v1:0",
          "arn:aws:bedrock:${var.aws_region}::foundation-model/anthropic.claude-opus-4-20250514-v1:0",
          "arn:aws:bedrock:${var.aws_region}::foundation-model/meta.llama3-70b-instruct-v1:0",
          "arn:aws:bedrock:${var.aws_region}::foundation-model/cohere.command-r-plus-v1:0",
        ]
      }
    ]
  })
}

##############################
# Bedrock Agent
##############################

# Bedrock Agent
resource "aws_bedrockagent_agent" "bedrock_agent_datetime" {
  agent_name              = "${var.app_name}-bedrock-agent"
  agent_resource_role_arn = aws_iam_role.role_bedrock_agent.arn
  foundation_model        = var.aws_bedrock_model

  instruction = <<EOT
You are a friendly and helpful assistant.

You have access to a function that provides the current date and time in UTC format. If a user asks for the current date, time, or anything related, you should call this function to retrieve accurate information.

Only include the date and time in your response after calling the function and receiving a value.

Be concise and informative in your replies.
EOT

  tags = {
    Project     = var.app_name
    Name        = "${var.app_name}-bedrock-agent"
    Environment = "prod"
  }
}

# wait for agent prepare
resource "time_sleep" "wait_agent" {
  create_duration = "5s"
  depends_on      = [aws_bedrockagent_agent.bedrock_agent_datetime]
}

# agent action group
resource "aws_bedrockagent_agent_action_group" "agent_action_group" {

  action_group_name          = "${var.app_name}-bedrock-agent-action-group"
  agent_id                   = aws_bedrockagent_agent.bedrock_agent_datetime.agent_id
  agent_version              = "DRAFT"
  skip_resource_in_use_check = true

  action_group_executor {
    lambda = aws_lambda_function.lambda_function_datetime.arn
  }

  api_schema {
    payload = file("../bedrock/action_group_schema.yaml")
  }

  depends_on = [time_sleep.wait_agent]
}

# Alias
resource "aws_bedrockagent_agent_alias" "agent_alias" {
  agent_alias_name = "${var.app_name}-bedrock-agent-alias"
  agent_id         = aws_bedrockagent_agent.bedrock_agent_datetime.agent_id
  description      = "Bedrock agent alias"

  tags = {
    Project     = var.app_name
    Name        = "${var.app_name}-agent-alias"
    Environment = "prod"
  }
}
