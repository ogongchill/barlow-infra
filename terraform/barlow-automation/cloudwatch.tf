resource "aws_cloudwatch_log_group" "ack" {
  name              = "/aws/lambda/barlow-ack"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "worker" {
  name              = "/aws/lambda/barlow-worker"
  retention_in_days = 30 # AI agent 트레이스 포함
}
