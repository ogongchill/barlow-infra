# 커밋 컨벤션

## 형식

`<type>(<scope>): <subject>`

파괴적 변경은 `!`를 붙인다: `feat(network)!: vpc cidr 대역 변경`

## type

| type | 설명 |
|------|------|
| `feat` | 새 리소스/기능 추가 |
| `fix` | 설정 오류/버그 수정 |
| `refactor` | 동작 변화 없이 구조 정리 |
| `chore` | 도구/스크립트/정리성 작업 |
| `docs` | 문서 작성 |
| `revert` | 변경 되돌리기 |

## scope

| scope | 대상 |
|-------|------|
| `network` | VPC, Subnet, Route, NAT, IGW |
| `security` | IAM, KMS, SG, WAF |
| `compute` | EC2, ECS, Lambda, LaunchTemplate |
| `data` | RDS, DynamoDB, ElastiCache, S3 |
| `edge` | CloudFront, Route53, ACM |
| `monitoring` | CloudWatch, Logs, Alarms |
| `pipeline` | CodeBuild, CodePipeline, GitHub Actions |
| `env` | 환경별 파라미터 분리 |

## subject

- 현재형 동사로 시작 (add, fix, restrict)
- 72자 이내

## 위험 변경 시 body 작성

네트워크/보안 변경, 데이터 파괴 가능성, 롤백이 까다로운 경우:

```
feat(network): nat gateway 경로로 private subnet 라우팅 추가

Impact: private subnet egress가 NAT로 변경됨
Rollback: 이 커밋 revert 후 스택 업데이트
```
