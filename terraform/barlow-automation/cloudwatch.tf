resource "aws_cloudwatch_log_group" "ack" {
  name              = "/aws/lambda/${aws_lambda_function.ack.function_name}"
  retention_in_days = 14

  tags = merge(local.tags, { Name = "/aws/lambda/${aws_lambda_function.ack.function_name}" })
}

resource "aws_cloudwatch_log_group" "worker" {
  name              = "/aws/lambda/${aws_lambda_function.worker.function_name}"
  retention_in_days = 30 # AI agent 트레이스 포함

  tags = merge(local.tags, { Name = "/aws/lambda/${aws_lambda_function.worker.function_name}" })
}
