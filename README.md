# prun e-commerce (website-java)

Spring Boot + React 이커머스 데모를 **AWS 3-tier**로 배포하는 프로젝트.
EC2에 **코드를 네이티브로 구동**(Docker 미사용)하며, **최초는 S3 시드로 직접 배포**,
**이후는 CodePipeline**(GitHub → CodeBuild → CodeDeploy)으로 배포한다.

## 구성

```
website-java/
├── backend/     Spring Boot 4 (Java 17) REST API  — appspec.yml / scripts / buildspec.yml
├── frontend/    React 19 + Vite SPA (nginx 서빙)   — appspec.yml / scripts / buildspec.yml
└── terraform/   AWS 3-tier IaC (VPC~CI/CD 전부)     — 배포 상세는 terraform/README.md
```

## 아키텍처

```
Internet
  │ HTTPS
  ▼
CloudFront ──HTTP──▶ Public ALB (CloudFront IP만 허용)
                        │ 8080
                        ▼
                 Frontend ASG (AL2023 + nginx)  m5.large · 2~6대 · CPU 70%
                        │ nginx가 /api,/actuator 프록시
                        ▼
                 Internal ALB (internal)
                        │ 8080
                        ▼
                 Backend ASG (AL2023 + Corretto17 systemd)  m5.large · 2~6대 · CPU 70%
                   ├── MySQL 3306 ─▶ RDS (Multi-AZ)          db.t3.small
                   └── Redis 6379 ─▶ ElastiCache (세션)       cache.t3.small
```

- **세션**: 백엔드가 Spring Session Data Redis로 HTTP 세션을 ElastiCache에 저장 → 오토스케일된
  어느 인스턴스로 라우팅돼도 동일 세션.
- **3-tier**: 프론트 nginx가 `/api`·`/actuator`를 internal ALB로 리버스 프록시 → 백엔드는 완전 private.

## 로컬 개발

```bash
# 백엔드 (H2, local 프로파일)
cd backend && ./gradlew bootRun

# 프론트 (Vite dev, 백엔드 localhost:8080 호출)
cd frontend && npm install && npm run dev
```

## AWS 배포 (요약)

상세: [`terraform/README.md`](terraform/README.md)

1. `terraform/terraform.prod.tfvars`의 `ssh_key_name`, `github_*` 설정
2. `cd terraform && terraform init && terraform apply -var-file=terraform.prod.tfvars`
3. `terraform output github_connection_arn` → 콘솔에서 GitHub 연결 **Pending → Available** 승인(최초 1회)
4. 로컬 빌드 후 `terraform output seed_upload_commands`대로 S3 시드 업로드 → `terraform output site_url` 접속
5. 이후 `main` 브랜치 push마다 CodePipeline이 자동 빌드·배포

## 기술 스택

- Backend: Spring Boot 4, Java 17, JPA/Hibernate, Spring Session (Redis), MySQL
- Frontend: React 19, Vite, React Router, Axios, nginx
- Infra: Terraform, VPC 3-tier, ALB, ASG, RDS MySQL, ElastiCache Redis, CloudFront, CodePipeline/CodeBuild/CodeDeploy
