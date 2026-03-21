# ── Ack Lambda ──────────────────────────────────────────────
resource "aws_lambda_function" "ack" {
  function_name = "barlow-slack-ack"
  role          = aws_iam_role.ack.arn
  runtime       = "python3.12"
  handler       = "src.controller.lambda_ack.handler"
  timeout       = 29 # Slack 3초 ack 제한 — 실제 처리는 SQS로 위임
  memory_size   = 256
  architectures = ["arm64"]
  s3_bucket     = "barlow-deploy-bucket"
  s3_key        = "automation/placeholder.zip" # 최초 1회 수동 업로드 필요

  environment {
    variables = {
      SLACK_BOT_TOKEN           = data.aws_ssm_parameter.slack_bot_token.value
      SLACK_SIGNING_SECRET      = data.aws_ssm_parameter.slack_signing_secret.value
      OPENAI_API_KEY            = data.aws_ssm_parameter.openai_api_key.value
      SQS_QUEUE_URL             = aws_sqs_queue.queue.url
      GITHUB_TOKEN              = data.aws_ssm_parameter.github_token.value
      TARGET_REPO               = data.aws_ssm_parameter.target_repo.value
      WORKFLOW_TABLE_NAME       = aws_dynamodb_table.workflow.name
      PENDING_ACTION_TABLE_NAME = aws_dynamodb_table.pending_action.name
      ACTIVE_SESSION_TABLE_NAME = aws_dynamodb_table.active_session.name
    }
  }

  tags = merge(local.tags, { Name = "barlow-slack-ack" })

  lifecycle {
    ignore_changes = [s3_key, s3_object_version]
  }
}

resource "aws_lambda_function_url" "ack" {
  function_name      = aws_lambda_function.ack.function_name
  authorization_type = "NONE" # Slack 서명 검증은 Bolt 미들웨어가 담당

  cors {
    allow_origins = ["https://slack.com"]
    allow_methods = ["POST"]
  }
}

resource "aws_lambda_permission" "ack_url" {
  statement_id           = "AllowPublicAccess"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.ack.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}

resource "aws_lambda_permission" "ack_invoke" {
  statement_id  = "AllowPublicInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ack.function_name
  principal     = "*"
}

# ── Worker Lambda ────────────────────────────────────────────
resource "aws_lambda_function" "worker" {
  function_name = "barlow-automation-worker"
  role          = aws_iam_role.worker.arn
  runtime       = "python3.12"
  handler       = "src.app.handlers.step_worker_handler.handler"
  timeout       = 900 # AI agent + GitHub MCP 호출 포함, 최대 15분
  memory_size   = 512
  architectures = ["arm64"]
  s3_bucket     = "barlow-deploy-bucket"
  s3_key        = "automation/placeholder.zip" # 최초 1회 수동 업로드 필요

  environment {
    variables = {
      SLACK_BOT_TOKEN           = data.aws_ssm_parameter.slack_bot_token.value
      SLACK_SIGNING_SECRET      = data.aws_ssm_parameter.slack_signing_secret.value
      SQS_QUEUE_URL             = aws_sqs_queue.queue.url
      OPENAI_API_KEY            = data.aws_ssm_parameter.openai_api_key.value
      GITHUB_TOKEN              = data.aws_ssm_parameter.github_token.value
      TARGET_REPO               = data.aws_ssm_parameter.target_repo.value
      WORKFLOW_TABLE_NAME       = aws_dynamodb_table.workflow.name
      PENDING_ACTION_TABLE_NAME = aws_dynamodb_table.pending_action.name
      ACTIVE_SESSION_TABLE_NAME = aws_dynamodb_table.active_session.name
    }
  }

  tags = merge(local.tags, { Name = "barlow-automation-worker" })

  lifecycle {
    ignore_changes = [s3_key, s3_object_version]
  }
}

resource "aws_lambda_event_source_mapping" "worker_sqs" {
  event_source_arn = aws_sqs_queue.queue.arn
  function_name    = aws_lambda_function.worker.arn
  batch_size       = 1 # 멱등성 보장 — 2 이상이면 동일 워크플로우 병렬 실행 위험

  tags = local.tags
}
