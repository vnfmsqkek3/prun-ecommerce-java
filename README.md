# 콘서트 티켓팅 (좌석 예약 + 대기열)

대량 트래픽 대비 **Redis 기반 대기열**(놀이공원 방식)과 **비관적 락 좌석 예약**을 갖춘 콘서트 티켓팅 데모.
참고: https://jhkang-tech.tistory.com/754

## 구성

```
website-java/
├── queue-server/   대기열 서버 (Spring Boot) — 토큰 발급 + Redis Sorted Set 대기열 + 10초 승격 스케줄러
├── backend/        예약 서버 (Spring Boot) — 콘서트/좌석/예약, 비관적 락, 예약 전 토큰 검증
├── frontend/       React SPA — 공연목록 → 대기열 → 좌석맵 → 예약완료
└── docker-compose.yml   mysql + redis + queue + backend + frontend
```

## 아키텍처 / 흐름

```
브라우저
  │  공연 선택 → 예매하기
  ▼
[대기열 서버]  POST /api/queue/{concertId}/enter  → 토큰 발급
  │  Redis ZSET waiting:concert:{id} (score=진입시각)
  │  스케줄러 10초마다 capacity 만큼 waiting → active(ZSET, 10분 TTL) 로 승격
  │  프론트가 /status 폴링 → 내 순번 표시, ONGOING 되면 입장
  ▼
[예약 서버]  POST /api/reservations {concertId, seatId, userId, token}
  │  1) 대기열 서버에 토큰 검증(active?)  2) 좌석 비관적 락(SELECT ... FOR UPDATE)
  │  3) AVAILABLE 이면 예약 + active 슬롯 반납(다음 대기자 입장)
  ▼
MySQL(콘서트/좌석/예약) + Redis(대기열/토큰)
```

- **대기열**: `waiting:concert:{id}`(ZSET) → `active:concert:{id}`(ZSET, 만료시각 score). 먼저 온 순서(score=진입시각)로 승격.
- **동시성**: 좌석은 `@Lock(PESSIMISTIC_WRITE)` 로 잠가 같은 좌석 동시 예약 시 하나만 성공 → 중복예약 방지.

## 로컬 실행

```bash
docker compose up --build
# 접속: http://localhost:3000
```
- 데모 설정: `QUEUE_CAPACITY=3` (동시 3명 입장, 4번째부터 대기). 여러 탭/시크릿창으로 대기열 확인 가능.
- 개별 실행(dev): 백엔드 `./gradlew bootRun`(8080), 대기열 `./gradlew bootRun`(8081), 프론트 `npm run dev`(vite proxy 로 라우팅).

### Docker 없이 빠른 확인 (H2)
백엔드를 `--spring.profiles.active=local` 로 띄우면 MySQL 없이 H2 로 동작(대기열 서버는 Redis 필요).

## 주요 API
| 서버 | 메서드 | 경로 | 설명 |
|---|---|---|---|
| queue | POST | `/api/queue/{id}/enter?userId=` | 대기열 입장(토큰 발급) |
| queue | GET | `/api/queue/{id}/status?token=` | 내 순번/입장여부 폴링 |
| queue | GET | `/api/queue/{id}/validate?token=` | (내부) 토큰 유효성 |
| backend | GET | `/api/concerts` / `/{id}` / `/{id}/seats` | 공연/좌석 조회 |
| backend | POST | `/api/reservations` | 좌석 예약(토큰 검증 + 비관적 락) |

## AWS 배포 (`terraform/`)
기존 인프라를 재활용해 콘서트 티켓팅용으로 구성 완료:

```
CloudFront ─┬ default → S3 (React SPA)
            └ /api/*  → API ALB(internet-facing, CloudFront-locked)
                        ├ /api/queue/* → queue TG  → Queue ASG  ── ElastiCache(Redis, redis 프로파일)
                        └ /api/*        → backend TG → Backend ASG ── RDS(MySQL)
backend → 같은 ALB로 /api/queue 호출(토큰 검증) — api_alb SG 에 app SG 허용
```
- 티어: **backend ASG + queue ASG**(각 CodePipeline/CodeDeploy), 프론트 S3+CloudFront.
- 대기열은 AWS 에선 **redis 프로파일**(ElastiCache 공유)로 스케일아웃.
- 카카오 알림톡은 `kakao_*` 변수(기본 빈값=로그) — 제공사 키 넣으면 실제 발송.
- 배포: `terraform apply -var-file=terraform.prod.tfvars` → GitHub 연결 승인 →
  `terraform output initial_deploy_commands`(backend/queue seed jar + 프론트 S3 sync) → 이후 push 시 파이프라인 자동.

> 참고: e-commerce 잔재(media S3 버킷 + CloudFront `/media/*`)는 티켓팅에서 미사용이나 무해하게 남아있음.
