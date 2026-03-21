data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# ── barlow-ack-role ──────────────────────────────────────────
resource "aws_iam_role" "ack" {
  name               = "barlow-automation-ack-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = merge(local.tags, { Name = "barlow-automation-ack-role" })
}

resource "aws_iam_role_policy" "ack_sqs" {
  name = "ack-sqs-send"
  role = aws_iam_role.ack.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["sqs:SendMessage"]
      Resource = aws_sqs_queue.queue.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ack_logs" {
  role       = aws_iam_role.ack.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ── barlow-worker-role ───────────────────────────────────────
resource "aws_iam_role" "worker" {
  name               = "barlow-automation-worker-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = merge(local.tags, { Name = "barlow-automation-worker-role" })
}

resource "aws_iam_role_policy" "worker_permissions" {
  name = "automation-worker-sqs-dynamo"
  role = aws_iam_role.worker.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.queue.arn
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem"
        ]
        Resource = [
          aws_dynamodb_table.workflow.arn,
          aws_dynamodb_table.pending_action.arn,
          aws_dynamodb_table.active_session.arn,
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "worker_logs" {
  role       = aws_iam_role.worker.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ── barlow-deployer-role (GitHub Actions OIDC) ───────────────
# 동일 AWS 계정에 GitHub OIDC Provider가 이미 등록되어 있을 경우 data source로 참조
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "deployer_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:ogongchill/barlow-automation:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "deployer" {
  name               = "automation-deployer-role"
  assume_role_policy = data.aws_iam_policy_document.deployer_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy" "deployer_permissions" {
  name = "automation-deployer-permissions"
  role = aws_iam_role.deployer.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "arn:aws:s3:::barlow-deploy-bucket/barlow/automation/*"
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:UpdateFunctionCode",
          "lambda:GetFunction"
        ]
        Resource = [
          aws_lambda_function.ack.arn,
          aws_lambda_function.worker.arn,
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["ssm:PutParameter"]
        Resource = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/barlow/deploy/*"
      }
    ]
  })
}
