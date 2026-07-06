# furn e-commerce — AWS (Terraform)

정적은 **S3+CloudFront**, 동적 API는 **ALB+ASG(네이티브 EC2)**, 데이터는 **RDS/ElastiCache**.
**단일 CloudFront**가 경로로 오리진을 분기한다.

## 아키텍처

```
Internet
  │ HTTPS
  ▼
CloudFront ─┬─ default        → S3 static (SPA)        [OAC]
            ├─ /media/*        → S3 media (업로드 이미지) [OAC, 캐싱]
            ├─ /api/*          → API ALB ─8080─▶ Backend ASG (AL2023 + Corretto17 systemd)
            └─ /actuator/*     → API ALB               │   m5.large · 2~4대 · CPU 70%
                                                       ├── MySQL 3306 ─▶ RDS (Multi-AZ)      db.t3.small
      API ALB: internet-facing, SG로 CloudFront IP만    └── Redis 6379 ─▶ ElastiCache (세션)  cache.t3.small
```

- **정적**: 프론트 빌드(dist)를 S3 static 버킷에 두고 CloudFront가 서빙(OAC, 딥링크 403/404→index.html).
- **미디어**: 백엔드가 업로드 이미지를 media 버킷에 저장(**VPC S3 gateway endpoint 경유**, IAM에 SourceVpce 강제).
  CloudFront `/media/*`가 media 버킷을 캐싱 서빙. 반환 URL은 상대경로 `/media/<uuid>.<ext>`.
- **동적**: 브라우저는 CloudFront 단일 도메인만 상대 호출 → `/api`는 CloudFront가 API ALB로 라우팅(same-origin, CORS 불필요, 세션쿠키 정상).
- **세션**: 백엔드가 Spring Session Data Redis로 ElastiCache에 세션 저장(오토스케일 공유).

## 서브넷 (VPC 10.100.0.0/20, 4 tier × 2 AZ = 8 subnets, /24)

| tier | 용도 | RT outbound |
|---|---|---|
| public | API ALB, NAT, EICE | IGW |
| app | Backend ASG | NAT (AZ별) |
| cache | ElastiCache Redis | 없음(격리) |
| db | RDS MySQL | 없음(격리) |

라우팅테이블 5개: public 1, app AZ별 2, cache 1, db 1.

## 배포 모델

- **백엔드**: 최초 = `terraform apply` 후 S3 seed jar 업로드 → EC2 user-data가 받아 systemd 구동.
  이후 = GitHub push → CodePipeline(Source→Build→**CodeDeploy** ASG 인플레이스).
- **프론트**: GitHub push → CodePipeline(Source→**Build**: npm build + S3 sync + CloudFront 무효화). EC2 없음.

## 배포 순서

### 0. 사전 준비
- EC2 key pair → `terraform.prod.tfvars`의 `ssh_key_name`.
- `github_owner`/`github_repo`/`github_branch` 확인.

### 1. 인프라 생성
```bash
cd terraform
terraform init
terraform apply -var-file=terraform.prod.tfvars
```

### 2. GitHub 연결 승인 (최초 1회)
```bash
terraform output github_connection_arn
```
→ 콘솔 Developer Tools > Connections 에서 **Pending → Available** 승인.

### 3. 최초 배포 (코드 바로 올리기)
```bash
terraform output initial_deploy_commands
```
- `backend_seed`: jar 빌드 후 S3 seed 업로드 → 백엔드 인스턴스 교체 시 기동.
- `frontend_static`: `npm build` → S3 sync → CloudFront 무효화.
→ `terraform output site_url` (CloudFront HTTPS) 접속.

### 4. 이후 배포 (자동)
`main` 브랜치 push → `furn-prod-frontend-pipeline` / `furn-prod-backend-pipeline` 자동 실행.

## 미디어 업로드 사용
`POST /api/media` (multipart `file`) → `{ "url": "/media/<uuid>.<ext>" }`.
이 url을 상품 `image_url` 등에 저장하면 CloudFront `/media`로 서빙됨. (prod 프로파일에서만 활성)

## 단순화 메모 (ponytail)
- 암호화 AWS 관리형 키(aws/rds, aws/ebs, SSE-S3). 전용 KMS CMK 미도입.
- Redis TLS 미사용(private subnet 격리 전제). ALB HTTPS는 CloudFront에서 종료.
- DB 삭제보호/최종스냅샷 데모 기본값(off/skip) — 실운영 tfvars에서 on.
- 관측성(CW agent 실제 설치·알람) 미포함. Remote state backend 미설정.
- `frontend/Dockerfile`·`nginx.conf`·`docker-entrypoint.sh`, `backend/Dockerfile`은 이 배포 경로에서 미사용(로컬 컨테이너용 잔존).
