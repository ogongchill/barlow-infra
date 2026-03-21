# SSM Parameter Store에서 시크릿을 읽어 Lambda env var에 주입.
# 파라미터는 최초 1회 수동 생성:
#   aws ssm put-parameter --name "/barlow/slack-bot-token" --value "xoxb-..." --type SecureString
#   aws ssm put-parameter --name "/barlow/slack-signing-secret" --value "..." --type SecureString
#   aws ssm put-parameter --name "/barlow/openai-api-key" --value "sk-..." --type SecureString
#   aws ssm put-parameter --name "/barlow/anthropic-api-key" --value "sk-ant-..." --type SecureString
#   aws ssm put-parameter --name "/barlow/github-token" --value "ghp_..." --type SecureString
#   aws ssm put-parameter --name "/barlow/target-repo" --value "ogongchill/barlow-infra" --type String

data "aws_ssm_parameter" "slack_bot_token" {
  name            = "/barlow/automation/slack-bot-token"
  with_decryption = true
}

data "aws_ssm_parameter" "slack_signing_secret" {
  name            = "/barlow/automation/slack-signing-secret"
  with_decryption = true
}

data "aws_ssm_parameter" "openai_api_key" {
  name            = "/barlow/automation/openai-api-key"
  with_decryption = true
}

data "aws_ssm_parameter" "github_token" {
  name            = "/barlow/automation/github-token"
  with_decryption = true
}

data "aws_ssm_parameter" "target_repo" {
  name            = "/barlow/automation/target-repo"
  with_decryption = true
}
