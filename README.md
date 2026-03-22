# barlow-infra

Barlow 프로젝트의 IaC(Infrastructure as Code) 템플릿을 관리하는 저장소입니다.

## 디렉토리 구조

```
.
├── server/                    # 서버 인프라 (CloudFormation 템플릿)
├── mobile/                    # 모바일 인프라
└── terraform/
    └── barlow-automation/     # Slack 자동화 봇 인프라 (Terraform)
```

## server

| 템플릿 | 설명 |
|--------|------|
| `ec2-test-template.yml` | 테스트용 스팟 EC2 인스턴스 + Security Group |

## terraform/barlow-automation

Slack 커맨드를 받아 GitHub 작업을 자동화하는 봇 인프라입니다.

### 아키텍처

```
Slack → Lambda (ack) → SQS → Lambda (worker) → GitHub / DynamoDB
```

- **barlow-slack-ack**: Slack 요청을 3초 내 수신 후 SQS에 위임
- **barlow-automation-worker**: SQS 메시지를 소비해 AI 에이전트 실행 (최대 15분)

### 리소스

| 리소스 | 이름 | 설명 |
|--------|------|------|
| Lambda | `barlow-slack-ack` | Slack Webhook 수신 (arm64, 256MB) |
| Lambda | `barlow-automation-worker` | 작업 처리 (arm64, 512MB) |
| SQS | `barlow-automation-queue` | 작업 큐 (visibility timeout 900s) |
| SQS | `barlow-automation-queue-dlq` | Dead Letter Queue |
| DynamoDB | `barlow-automation-workflow` | 워크플로우 상태 |
| DynamoDB | `barlow-automation-pending-action` | 대기 중인 액션 |
| DynamoDB | `barlow-automation-active-session` | 활성 세션 |

### 시크릿 관리

시크릿은 AWS SSM Parameter Store에서 관리하며 Terraform apply 시 Lambda 환경변수로 주입됩니다.

| SSM 경로 | 용도 |
|----------|------|
| `/barlow/automation/slack-bot-token` | Slack Bot Token |
| `/barlow/automation/slack-signing-secret` | Slack Signing Secret |
| `/barlow/automation/openai-api-key` | OpenAI API Key |
| `/barlow/automation/github-token` | GitHub Token |
| `/barlow/automation/target-repo` | 대상 GitHub 레포 |

### CI/CD

`.github/workflows/terraform-automation.yml`

| 이벤트 | 동작 |
|--------|------|
| PR → main | `terraform plan` 결과 PR 코멘트 |
| push → main | `terraform apply -auto-approve` |

- Terraform state: `s3://barlow-terraform/barlow/automation/terraform.tfstate`
- Lambda 코드 배포: `barlow-automation` 레포의 GitHub Actions (`automation-deployer-role` OIDC)
