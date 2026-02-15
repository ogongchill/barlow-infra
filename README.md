# barlow-infra

Barlow 프로젝트의 IaC(Infrastructure as Code) 템플릿을 관리하는 저장소입니다.

## 디렉토리 구조

```
.
├── server/    # 서버 인프라 (CloudFormation 템플릿 등)
└── mobile/    # 모바일 인프라
```

## server

| 템플릿 | 설명 |
|--------|------|
| `ec2-test-template.yml` | 테스트용 스팟 EC2 인스턴스 + Security Group |
