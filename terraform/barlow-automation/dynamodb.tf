# ── barlow-workflow ───────────────────────────────────────────
# 워크플로우 인스턴스 저장. 각 사용자 요청당 하나의 레코드.
resource "aws_dynamodb_table" "workflow" {
  name         = "barlow-workflow"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "workflow_id"

  attribute {
    name = "workflow_id"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = { env = var.env }
}

# ── barlow-pending-action ─────────────────────────────────────
# SQS 이벤트 멱등성 처리. 동일 메시지 중복 처리 방지.
resource "aws_dynamodb_table" "pending_action" {
  name         = "barlow-pending-action"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"

  attribute {
    name = "pk"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = { env = var.env }
}

# ── barlow-active-session ─────────────────────────────────────
# 채널+유저 단위 활성 워크플로우 추적. 동일 사용자 중복 시작 방지.
resource "aws_dynamodb_table" "active_session" {
  name         = "barlow-active-session"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"

  attribute {
    name = "pk"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = { env = var.env }
}
