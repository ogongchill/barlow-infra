resource "aws_sqs_queue" "dlq" {
  name                      = "barlow-queue-dlq"
  message_retention_seconds = 1209600 # 14일
}

resource "aws_sqs_queue" "queue" {
  name                       = "barlow-queue"
  visibility_timeout_seconds = 900 # Worker Lambda timeout과 반드시 동일해야 함
  message_retention_seconds  = 86400 # 24h
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 2
  })
}
