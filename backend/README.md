# E-Commerce Demo Application

> 인프라 레벨 현대화 시연을 위한 데모 이커머스 애플리케이션

## 📋 프로젝트 개요

이 프로젝트는 AWS 인프라 현대화 과정을 시연하기 위한 데모 애플리케이션입니다.
Monolithic 아키텍처에서 Microservices로, EC2 기반에서 Container 기반(ECS)으로,
Self-managed 서비스에서 AWS Managed Services로의 전환 과정을 단계별로 보여줍니다.

### 주요 기능

- **상품 관리**: 상품 등록, 조회, 수정, 삭제
- **주문 관리**: 주문 생성, 조회, 상태 변경, 취소
- **사용자 관리**: 회원가입, 로그인, 정보 조회/수정
- **장바구니 관리**: 상품 추가/삭제, 수량 변경, 장바구니 기반 주문

## 🛠 기술 스택

- **Language**: Java 17
- **Framework**: Spring Boot 4.0.0
- **Build Tool**: Gradle 8.14
- **Database**: H2 (Development) → MySQL (Production)
- **ORM**: Spring Data JPA

## 📁 프로젝트 구조

```
ecommerce-demo/
├── src/
│   ├── main/
│   │   ├── java/com/example/ecommercedemo/
│   │   │   ├── controller/      # REST API Controllers
│   │   │   ├── service/         # Business Logic
│   │   │   ├── repository/      # Data Access Layer
│   │   │   ├── entity/          # JPA Entities
│   │   │   ├── dto/             # Data Transfer Objects
│   │   │   └── exception/       # Custom Exceptions
│   │   └── resources/
│   │       └── application.properties
│   └── test/
├── REQUIREMENTS.md              # 요구사항 명세서 (한글)
├── REQUIREMENTS_EN.md           # Requirements Specification (English)
├── DEVELOPMENT_RULES.md         # 개발 규칙 (한글)
├── DEVELOPMENT_RULES_EN.md      # Development Rules (English)
├── PLAN.md                      # Sprint별 작업 계획
└── README.md
```

## 🚀 시작하기

### 사전 요구사항

- Java 17 이상
- Gradle 8.14 이상

### 로컬 실행

1. **프로젝트 클론**
```bash
git clone <repository-url>
cd ecommerce-demo
```

2. **빌드**
```bash
./gradlew clean build
```

3. **실행**

**로컬 환경 (H2 Database):**
```bash
./gradlew bootRun
# 또는
./gradlew bootRun --args='--spring.profiles.active=local'
```

**개발 환경 (MySQL):**
```bash
./gradlew bootRun --args='--spring.profiles.active=dev'
```

**운영 환경 (RDS MySQL):**
```bash
./gradlew bootRun --args='--spring.profiles.active=prod'
```

4. **접속**
- Application: http://localhost:8080
- H2 Console (local 환경만): http://localhost:8080/h2-console
  - JDBC URL: `jdbc:h2:mem:testdb`
  - Username: `sa`
  - Password: (empty)

### 환경별 설정

| 환경 | Profile | Database | DDL Auto | 설명 |
|------|---------|----------|----------|------|
| Local | local | H2 (In-memory) | create-drop | 로컬 개발 환경 |
| Dev | dev | MySQL | update | 개발 서버 환경 |
| Prod | prod | RDS MySQL | validate | 운영 환경 |

## 📚 API 문서

### 상품 API

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/products` | 상품 등록 |
| GET | `/api/products` | 상품 목록 조회 |
| GET | `/api/products/{id}` | 상품 상세 조회 |
| PUT | `/api/products/{id}` | 상품 수정 |
| DELETE | `/api/products/{id}` | 상품 삭제 |

### 주문 API

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/orders` | 주문 생성 |
| POST | `/api/orders/from-cart` | 장바구니 기반 주문 생성 |
| GET | `/api/orders` | 주문 목록 조회 |
| GET | `/api/orders/{id}` | 주문 상세 조회 |
| PATCH | `/api/orders/{id}/status` | 주문 상태 변경 |
| POST | `/api/orders/{id}/cancel` | 주문 취소 |

### 사용자 API

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/users/signup` | 회원가입 |
| POST | `/api/users/login` | 로그인 |
| GET | `/api/users/me` | 내 정보 조회 |
| PUT | `/api/users/me` | 내 정보 수정 |
| PUT | `/api/users/me/password` | 비밀번호 변경 |

### 장바구니 API

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/carts/items` | 장바구니에 상품 추가 |
| GET | `/api/carts` | 장바구니 조회 |
| PUT | `/api/carts/items/{id}` | 장바구니 상품 수량 변경 |
| DELETE | `/api/carts/items/{id}` | 장바구니 상품 삭제 |
| DELETE | `/api/carts` | 장바구니 전체 비우기 |

### 헬스 체크

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/actuator/health` | 애플리케이션 상태 확인 |

## 🔄 인프라 현대화 단계

### Phase 1: 레거시 모놀리식 (현재)
- 단일 Spring Boot 애플리케이션
- H2 인메모리 데이터베이스
- EC2 단일 인스턴스 배포

### Phase 2: 데이터베이스 현대화
- H2 → MySQL 전환
- EC2 MySQL → Amazon RDS for MySQL
- 커넥션 풀 최적화

### Phase 3: 컨테이너화
- Dockerfile 작성
- Amazon ECR 이미지 저장소
- Amazon ECS (Fargate) 배포
- Application Load Balancer 연결

### Phase 4: 마이크로서비스 분리
- Product Service 분리
- Order Service 분리
- User Service 분리
- 서비스간 REST API 통신

### Phase 5: AWS Managed Services 통합
- Amazon S3 (이미지 저장)
- Amazon ElastiCache (캐싱)
- Amazon SQS/SNS (비동기 처리)
- CloudWatch Logs (로깅)
- AWS Secrets Manager (시크릿 관리)

## 📖 문서

- [요구사항 명세서 (한글)](REQUIREMENTS.md)
- [Requirements Specification (English)](REQUIREMENTS_EN.md)
- [개발 규칙 (한글)](DEVELOPMENT_RULES.md)
- [Development Rules (English)](DEVELOPMENT_RULES_EN.md)
- [작업 계획](PLAN.md)

## 🧪 테스트

### HTTP Client 파일 사용

프로젝트에는 각 API를 테스트할 수 있는 `.http` 파일이 포함되어 있습니다.

```bash
# 애플리케이션 실행 후
# IntelliJ IDEA 또는 VS Code의 REST Client 플러그인으로 실행
```

### 빌드 및 테스트

```bash
# 전체 테스트 실행
./gradlew test

# 빌드 (테스트 포함)
./gradlew build

# 빌드 (테스트 제외)
./gradlew build -x test
```

## 🐳 Docker 실행 (Phase 3 이후)

### Docker 이미지 빌드

```bash
docker build -t ecommerce-demo:latest .
```

### Docker Compose 실행

```bash
docker-compose up -d
```

### 종료

```bash
docker-compose down
```

## 📝 개발 규칙

이 프로젝트는 Clean Code와 Effective Java의 모범 사례를 따릅니다.

### 구현 순서
1. DTO 작성
2. Service 구현
3. Controller 구현
4. HTTP Client 테스트

### 네이밍 컨벤션
- Controller: `{Domain}Controller`
- Service: `{Domain}Service`
- Repository: `{Domain}Repository`
- 메서드: `insert{Domain}`, `select{Domain}`, `update{Domain}`, `delete{Domain}`

자세한 내용은 [개발 규칙 문서](DEVELOPMENT_RULES.md)를 참조하세요.

## 🤝 기여 가이드

1. 작업 전 [PLAN.md](PLAN.md)에서 작업 항목 확인
2. [DEVELOPMENT_RULES.md](DEVELOPMENT_RULES.md) 규칙 준수
3. 기능 구현 후 HTTP Client로 테스트
4. 커밋 메시지 규칙 준수 (`feat:`, `fix:`, `docs:` 등)

## 📄 라이선스

This project is for demonstration purposes only.

## 👥 작성자

AWS Infrastructure Modernization Demo Team

---

**현재 진행 상황**: Sprint 4 완료 (장바구니 기능 구현 완료)

**구현 완료된 기능:**
- ✅ 상품 관리 (5개 API)
- ✅ 사용자 관리 (5개 API)
- ✅ 주문 관리 (6개 API)
- ✅ 장바구니 관리 (5개 API)
- ✅ 총 21개 API

자세한 진행 상황은 [PLAN.md](PLAN.md)를 참조하세요.
