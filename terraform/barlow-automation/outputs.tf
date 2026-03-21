output "slack_endpoint" {
  description = "Slack slash command URL (Lambda Function URL)"
  value       = aws_lambda_function_url.ack.function_url
}

output "queue_url" {
  description = "SQS barlow-queue URL"
  value       = aws_sqs_queue.queue.url
}

output "workflow_table" {
  description = "DynamoDB barlow-workflow table name"
  value       = aws_dynamodb_table.workflow.name
}

output "pending_action_table" {
  description = "DynamoDB barlow-pending-action table name"
  value       = aws_dynamodb_table.pending_action.name
}

output "active_session_table" {
  description = "DynamoDB barlow-active-session table name"
  value       = aws_dynamodb_table.active_session.name
}
