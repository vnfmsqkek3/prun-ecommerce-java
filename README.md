# prun e-commerce (website-java)

Spring Boot + React 이커머스 데모를 AWS에 배포하는 프로젝트.
**정적은 S3+CloudFront**, **동적 API는 ALB+ASG(네이티브 EC2)**, **미디어는 S3**, 단일 CloudFront가 경로로 분기한다.

## 구성

```
website-java/
├── backend/     Spring Boot 4 (Java 17) REST API  — appspec.yml / scripts / buildspec.yml (CodeDeploy)
├── frontend/    React 19 + Vite SPA               — buildspec.yml (S3 sync + CloudFront 무효화)
└── terraform/   AWS IaC (VPC~CI/CD 전부)           — 배포 상세는 terraform/README.md
```

## 아키텍처

```
Internet
  │ HTTPS
  ▼
CloudFront ─┬─ default     → S3 static (SPA)         [OAC]
            ├─ /media/*     → S3 media (업로드 이미지)  [OAC, 캐싱]
            ├─ /api/*       → API ALB ─8080─▶ Backend ASG (AL2023 + Corretto17 systemd)
            └─ /actuator/*  → API ALB               │   m5.large · 2~4대 · CPU 70%
                                                    ├── MySQL 3306 ─▶ RDS (Multi-AZ)      db.t3.small
        API ALB: internet-facing, CloudFront IP만    └── Redis 6379 ─▶ ElastiCache (세션)  cache.t3.small
```

- **정적**: 프론트 빌드(dist)를 S3에 두고 CloudFront가 OAC로 서빙(딥링크 403/404→index.html).
- **미디어**: 백엔드가 업로드 이미지를 media 버킷에 저장(**VPC S3 endpoint 경유**), CloudFront `/media/*`로 서빙.
- **동적**: 브라우저는 CloudFront 단일 도메인만 상대 호출 → `/api`는 CloudFront가 API ALB로 라우팅(same-origin).
- **세션**: 백엔드가 Spring Session Data Redis로 ElastiCache에 세션 저장(오토스케일 공유).

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
4. `terraform output initial_deploy_commands` 대로 최초 배포(백엔드 seed jar / 프론트 S3 sync) → `terraform output site_url` 접속
5. 이후 `main` 브랜치 push마다 CodePipeline이 자동 빌드·배포

## 미디어 업로드

`POST /api/media` (multipart `file`) → `{ "url": "/media/<uuid>.<ext>" }` (prod 전용). 이 url을 상품 `image_url` 등에 저장.

## 기술 스택

- Backend: Spring Boot 4, Java 17, JPA/Hibernate, Spring Session (Redis), MySQL, AWS SDK v2 (S3)
- Frontend: React 19, Vite, React Router, Axios
- Infra: Terraform, VPC, CloudFront(다중 오리진), ALB, ASG, RDS MySQL, ElastiCache Redis, S3(static/media), CodePipeline/CodeBuild/CodeDeploy
