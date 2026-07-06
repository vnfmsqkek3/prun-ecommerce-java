# furn e-commerce — AWS 3-tier (Terraform)

nanoh2o 컨벤션(평탄 구조, `furn-prod-*` 네이밍, tier별 서브넷/RT)을 미러링한 3-tier 인프라.
EC2에 **코드를 네이티브로 구동**(Docker 미사용), **최초는 S3 시드로 직접 배포**, **이후는 CodePipeline**.

## 아키텍처

```
Internet
  │ HTTPS
  ▼
CloudFront ──HTTP──▶ Public ALB (CloudFront IP만 허용)
                        │ 8080
                        ▼
                 Frontend ASG (AL2023 + nginx, private web subnet)  m5.large, 2~6대, CPU 70%
                        │ nginx가 /api,/actuator 프록시 (80→8080)
                        ▼
                 Internal ALB (internal)
                        │ 8080
                        ▼
                 Backend ASG (AL2023 + Corretto17 systemd, private app subnet)  m5.large, 2~6대, CPU 70%
                   ├── MySQL 3306 ─▶ RDS (Multi-AZ, private db subnet)   db.t3.small
                   └── Redis 6379 ─▶ ElastiCache (세션, private cache subnet)  cache.t3.small
```

## 배포 모델

**① 최초 (코드를 바로 EC2에):** `terraform apply` → EC2 user-data가 S3 `seed/`에서 코드를 받아
네이티브 구동(백엔드=systemd, 프론트=nginx). 시드가 없으면 CodeDeploy 첫 배포를 대기.

**② 이후 (CodePipeline):** GitHub push → CodePipeline(Source) → CodeBuild(빌드) →
CodeDeploy(ASG 인플레이스, TG 트래픽 제어 + 실패 시 자동 롤백).

- 인프라성 설정(DB/Redis env, nginx 프록시 대상)은 **user-data가 주입·유지**.
  CodeDeploy는 코드(app.jar / dist)만 교체 → 자격증명·엔드포인트는 배포 산출물에 안 들어감.

## 배포 순서

### 0. 사전 준비
- EC2 key pair 생성 → `terraform.prod.tfvars`의 `ssh_key_name`.
- `terraform.prod.tfvars`의 `github_owner` / `github_repo` / `github_branch`를 실제 값으로.

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
→ AWS 콘솔 > Developer Tools > Connections 에서 해당 연결을 **Pending → Available** 로 승인
(GitHub 앱 설치/권한 부여). 이걸 해야 CodePipeline Source가 동작.

### 3. 최초 시드 업로드 (코드를 바로 EC2에 올리기)
로컬에서 한 번 빌드해 S3 `seed/`에 올리면, 부팅한/재기동되는 EC2가 바로 실행:
```bash
# 백엔드 jar
cd backend && gradle wrapper && ./gradlew bootJar -x test && cd ..
# 프론트 dist
cd frontend && npm ci && npm run build && cd ..
# 업로드 (정확한 명령은 아래 output 참고)
terraform -chdir=terraform output seed_upload_commands
```
업로드 후 ASG 인스턴스를 교체(또는 instance refresh)하면 시드를 받아 뜸.
→ `terraform output site_url` (CloudFront HTTPS)로 접속.

### 4. 이후 배포 (자동)
GitHub 브랜치에 push → `furn-prod-frontend-pipeline` / `furn-prod-backend-pipeline` 자동 실행 →
CodeBuild 빌드 → CodeDeploy가 각 ASG에 롤링 배포.

## 앱 코드 연동 (이 인프라에 맞춰 수정/추가된 것)

- **backend**: Redis 세션(`spring-session-data-redis`), 로그인 시 `HttpSession`에 userId 저장(ElastiCache).
  prod `ddl-auto=update`(빈 RDS 자동 스키마). `appspec.yml` + `scripts/` + `buildspec.yml`(네이티브 jar 번들).
- **frontend**: `api.js` same-origin, `appspec.yml` + `scripts/` + `buildspec.yml`(네이티브 dist 번들).
  nginx 프록시 설정은 user-data가 생성(프록시 대상=internal ALB).
- 참고: `frontend/Dockerfile`·`nginx.conf`·`docker-entrypoint.sh`, `backend/Dockerfile`는
  이 네이티브 배포 경로에서는 **미사용**(로컬 컨테이너 실행용으로만 잔존).

## 서브넷 (VPC 10.0.0.0/20, 5 tier × 2 AZ)

| tier   | 용도                 | RT outbound |
|--------|----------------------|-------------|
| public | ALB(web), NAT, EICE  | IGW         |
| web    | Frontend ASG         | NAT (AZ별)  |
| app    | Backend ASG, Int ALB | NAT (AZ별)  |
| cache  | ElastiCache Redis    | 없음(격리)  |
| db     | RDS MySQL            | 없음(격리)  |

## 단순화 메모 (ponytail)

- 암호화는 AWS 관리형 키(aws/rds, aws/ebs, SSE-S3). 전용 KMS CMK 미도입.
- Redis transit encryption(TLS) 미사용(private subnet 격리 전제).
- ALB HTTPS(ACM)는 CloudFront에서 종료. 커스텀 도메인은 ACM+alias로 승격.
- DB 삭제보호/최종스냅샷은 데모 기본값(off/skip). 실운영은 tfvars에서 켤 것.
- 관측성(CloudWatch agent 실제 설치·알람)은 미포함(IAM 권한만 준비).
- Remote state backend 미설정(로컬 state). 팀 운영 시 S3+DynamoDB backend 추가.
