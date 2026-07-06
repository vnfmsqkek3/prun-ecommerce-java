# 이커머스 데모 애플리케이션 요구사항 명세서

## 1. 프로젝트 개요

### 1.1 목적
- 인프라 레벨 현대화 시연을 위한 데모 이커머스 애플리케이션
- Monolithic → Microservices 아키텍처 전환 과정 시연
- EC2 기반 → Container 기반(ECS) 전환 과정 시연
- Self-managed → AWS Managed Services 전환 과정 시연

### 1.2 기술 스택
- **언어/프레임워크**: Java 17, Spring Boot 4.0.0
- **빌드 도구**: Gradle 8.14
- **데이터베이스**: H2 (개발) → MySQL (운영)
- **ORM**: Spring Data JPA

## 2. 기능 요구사항

### 2.1 상품 관리 (Product Service)

#### 2.1.1 상품 등록
- **설명**: 새로운 상품을 등록한다
- **입력**:
  - 상품명 (필수, 최대 100자)
  - 설명 (선택, 최대 1000자)
  - 가격 (필수, 양수)
  - 재고 수량 (필수, 0 이상)
  - 카테고리 (필수)
  - 이미지 URL (선택)
- **출력**: 생성된 상품 정보 (상품 ID 포함)
- **검증**:
  - 상품명 중복 불가
  - 가격은 0보다 커야 함
  - 재고는 0 이상이어야 함

#### 2.1.2 상품 목록 조회
- **설명**: 등록된 상품 목록을 조회한다
- **입력**:
  - 페이지 번호 (기본값: 0)
  - 페이지 크기 (기본값: 20, 최대: 100)
  - 카테고리 필터 (선택)
  - 정렬 기준 (기본값: 최신순)
- **출력**: 페이징된 상품 목록
- **기능**:
  - 카테고리별 필터링
  - 가격순/최신순 정렬

#### 2.1.3 상품 상세 조회
- **설명**: 특정 상품의 상세 정보를 조회한다
- **입력**: 상품 ID
- **출력**: 상품 상세 정보
- **예외**: 존재하지 않는 상품 ID인 경우 404 에러

#### 2.1.4 상품 수정
- **설명**: 기존 상품 정보를 수정한다
- **입력**:
  - 상품 ID
  - 수정할 필드들 (부분 수정 가능)
- **출력**: 수정된 상품 정보
- **검증**: 상품 등록과 동일한 검증 규칙 적용

#### 2.1.5 상품 삭제
- **설명**: 상품을 삭제한다 (Soft Delete)
- **입력**: 상품 ID
- **출력**: 삭제 성공 메시지
- **제약**: 주문 내역이 있는 상품은 삭제 불가

### 2.2 주문 관리 (Order Service)

#### 2.2.1 주문 생성
- **설명**: 새로운 주문을 생성한다
- **입력**:
  - 사용자 ID (필수)
  - 주문 상품 목록 (필수, 최소 1개)
    - 상품 ID
    - 수량
- **출력**: 생성된 주문 정보 (주문 ID, 총 금액 포함)
- **처리 로직**:
  1. 상품 재고 확인
  2. 재고 차감
  3. 주문 총액 계산
  4. 주문 생성 (상태: PENDING)
- **검증**:
  - 재고 부족 시 주문 실패 (어떤 상품이 부족한지 명시)
  - 존재하지 않는 상품 ID 시 주문 실패
- **트랜잭션**: 재고 차감과 주문 생성은 원자적으로 처리

#### 2.2.2 장바구니 기반 주문 생성
- **설명**: 장바구니 내용으로 주문을 생성한다
- **입력**: 사용자 ID (헤더)
- **출력**: 생성된 주문 정보
- **처리 로직**:
  1. 장바구니 조회
  2. 장바구니 내용을 주문으로 변환
  3. 주문 생성 (기존 로직 재사용)
  4. 주문 성공 시 장바구니 비우기
- **검증**: 장바구니가 비어있으면 실패
- **트랜잭션**: 주문 생성과 장바구니 비우기는 원자적으로 처리

#### 2.2.3 주문 목록 조회
- **설명**: 사용자의 주문 목록을 조회한다
- **입력**:
  - 사용자 ID (필수)
  - 페이지 번호 (기본값: 0)
  - 페이지 크기 (기본값: 20)
  - 주문 상태 필터 (선택)
- **출력**: 페이징된 주문 목록
- **기능**: 주문 상태별 필터링

#### 2.2.4 주문 상세 조회
- **설명**: 특정 주문의 상세 정보를 조회한다
- **입력**: 주문 ID
- **출력**: 주문 상세 정보 (주문 상품 목록 포함)
- **검증**: 본인의 주문만 조회 가능

#### 2.2.5 주문 상태 변경
- **설명**: 주문 상태를 변경한다
- **입력**:
  - 주문 ID
  - 변경할 상태
- **출력**: 변경된 주문 정보
- **상태 전이**:
  - PENDING → CONFIRMED
  - PENDING → CANCELLED
- **검증**: 유효하지 않은 상태 전이는 불가

#### 2.2.6 주문 취소
- **설명**: 주문을 취소한다
- **입력**: 주문 ID
- **출력**: 취소된 주문 정보
- **처리 로직**:
  1. 주문 상태를 CANCELLED로 변경
  2. 재고 복구
- **제약**: PENDING 상태의 주문만 취소 가능

### 2.3 사용자 관리 (User Service)

#### 2.3.1 회원가입
- **설명**: 새로운 사용자를 등록한다
- **입력**:
  - 이메일 (필수, 이메일 형식)
  - 비밀번호 (필수, 최소 8자)
  - 이름 (필수, 최대 50자)
  - 전화번호 (선택)
- **출력**: 생성된 사용자 정보 (비밀번호 제외)
- **검증**:
  - 이메일 중복 불가
  - 이메일 형식 검증
  - 비밀번호 암호화 저장

#### 2.3.2 로그인
- **설명**: 사용자 인증을 수행한다
- **입력**:
  - 이메일
  - 비밀번호
- **출력**: 인증 토큰 (JWT) 또는 세션 ID
- **검증**:
  - 이메일/비밀번호 일치 확인
  - 로그인 실패 시 401 에러

#### 2.3.3 사용자 정보 조회
- **설명**: 로그인한 사용자의 정보를 조회한다
- **입력**: 인증 토큰
- **출력**: 사용자 정보 (비밀번호 제외)
- **검증**: 유효한 인증 토큰 필요

#### 2.3.4 사용자 정보 수정
- **설명**: 사용자 정보를 수정한다
- **입력**:
  - 인증 토큰
  - 수정할 필드들 (이름, 전화번호)
- **출력**: 수정된 사용자 정보
- **제약**: 이메일은 수정 불가

#### 2.3.5 비밀번호 변경
- **설명**: 사용자 비밀번호를 변경한다
- **입력**:
  - 인증 토큰
  - 현재 비밀번호
  - 새 비밀번호
- **출력**: 변경 성공 메시지
- **검증**:
  - 현재 비밀번호 일치 확인
  - 새 비밀번호 형식 검증

### 2.4 장바구니 관리 (Cart Service)

#### 2.4.1 장바구니에 상품 추가
- **설명**: 장바구니에 상품을 추가한다
- **입력**:
  - 사용자 ID (헤더)
  - 상품 ID (필수)
  - 수량 (필수, 최소 1)
- **출력**: 업데이트된 장바구니 정보
- **처리 로직**:
  - 장바구니가 없으면 자동 생성
  - 이미 있는 상품이면 수량 증가
  - 없는 상품이면 새로 추가

#### 2.4.2 장바구니 조회
- **설명**: 사용자의 장바구니를 조회한다
- **입력**: 사용자 ID (헤더)
- **출력**: 장바구니 정보 (상품 상세 정보 포함)
- **기능**: 실시간 상품 정보 반영 (이름, 가격)

#### 2.4.3 장바구니 상품 수량 변경
- **설명**: 장바구니 상품의 수량을 변경한다
- **입력**:
  - 사용자 ID (헤더)
  - 장바구니 상품 ID
  - 수량 (필수, 최소 1)
- **출력**: 업데이트된 장바구니 정보
- **검증**: 수량은 1 이상이어야 함

#### 2.4.4 장바구니 상품 삭제
- **설명**: 장바구니에서 특정 상품을 삭제한다
- **입력**:
  - 사용자 ID (헤더)
  - 장바구니 상품 ID
- **출력**: 삭제 성공 메시지

#### 2.4.5 장바구니 전체 비우기
- **설명**: 장바구니의 모든 상품을 삭제한다
- **입력**: 사용자 ID (헤더)
- **출력**: 삭제 성공 메시지

## 3. 비기능 요구사항

### 3.1 성능
- API 응답 시간: 평균 200ms 이하
- 동시 사용자: 100명 이상 처리 가능
- 데이터베이스 쿼리 최적화 (N+1 문제 방지)

### 3.2 보안
- 비밀번호 평문 저장 (데모 목적)
- SQL Injection 방지
- XSS 방지
- HTTPS 통신 (운영 환경)
- 인증/인가 처리 (간단한 헤더 기반)

### 3.3 확장성
- 수평 확장 가능한 구조
- Stateless 애플리케이션 설계
- 데이터베이스 커넥션 풀 관리

### 3.4 가용성
- 헬스 체크 엔드포인트 제공
- Graceful shutdown 지원
- 에러 핸들링 및 로깅

### 3.5 모니터링
- 애플리케이션 로그 (INFO, ERROR 레벨)
- API 호출 로그
- 에러 추적

## 4. 데이터 모델

### 4.1 Product (상품)
```
- id: Long (PK, Auto Increment)
- name: String (100자, NOT NULL, UNIQUE)
- description: String (1000자)
- price: BigDecimal (NOT NULL)
- stockQuantity: Integer (NOT NULL, >= 0)
- category: String (50자, NOT NULL)
- imageUrl: String (500자)
- deleted: Boolean (기본값: false)
- createdAt: LocalDateTime (NOT NULL)
- updatedAt: LocalDateTime (NOT NULL)
```

### 4.2 Order (주문)
```
- id: Long (PK, Auto Increment)
- userId: Long (FK, NOT NULL)
- status: Enum (PENDING, CONFIRMED, CANCELLED)
- totalAmount: BigDecimal (NOT NULL)
- createdAt: LocalDateTime (NOT NULL)
- updatedAt: LocalDateTime (NOT NULL)
```

### 4.3 OrderItem (주문 상품)
```
- id: Long (PK, Auto Increment)
- orderId: Long (FK, NOT NULL)
- productId: Long (FK, NOT NULL)
- productName: String (100자, NOT NULL)
- price: BigDecimal (NOT NULL)
- quantity: Integer (NOT NULL, > 0)
```

### 4.4 User (사용자)
```
- id: Long (PK, Auto Increment)
- email: String (100자, NOT NULL, UNIQUE)
- password: String (255자, NOT NULL, 평문)
- name: String (50자, NOT NULL)
- phoneNumber: String (20자)
- createdAt: LocalDateTime (NOT NULL)
- updatedAt: LocalDateTime (NOT NULL)
```

### 4.5 Cart (장바구니)
```
- id: Long (PK, Auto Increment)
- userId: Long (FK, NOT NULL, UNIQUE)
- createdAt: LocalDateTime (NOT NULL)
- updatedAt: LocalDateTime (NOT NULL)
```

### 4.6 CartItem (장바구니 상품)
```
- id: Long (PK, Auto Increment)
- cartId: Long (FK, NOT NULL)
- productId: Long (FK, NOT NULL)
- quantity: Integer (NOT NULL, > 0)
- UNIQUE (cartId, productId)
```

## 5. API 엔드포인트

### 5.1 상품 API
- `POST /api/products` - 상품 등록
- `GET /api/products` - 상품 목록 조회
- `GET /api/products/{id}` - 상품 상세 조회
- `PUT /api/products/{id}` - 상품 수정
- `DELETE /api/products/{id}` - 상품 삭제

### 5.2 주문 API
- `POST /api/orders` - 주문 생성
- `POST /api/orders/from-cart` - 장바구니 기반 주문 생성
- `GET /api/orders` - 주문 목록 조회
- `GET /api/orders/{id}` - 주문 상세 조회
- `PATCH /api/orders/{id}/status` - 주문 상태 변경
- `POST /api/orders/{id}/cancel` - 주문 취소

### 5.3 사용자 API
- `POST /api/users/signup` - 회원가입
- `POST /api/users/login` - 로그인
- `GET /api/users/me` - 내 정보 조회
- `PUT /api/users/me` - 내 정보 수정
- `PUT /api/users/me/password` - 비밀번호 변경

### 5.4 장바구니 API
- `POST /api/carts/items` - 장바구니에 상품 추가
- `GET /api/carts` - 장바구니 조회
- `PUT /api/carts/items/{id}` - 장바구니 상품 수량 변경
- `DELETE /api/carts/items/{id}` - 장바구니 상품 삭제
- `DELETE /api/carts` - 장바구니 전체 비우기

### 5.5 헬스 체크
- `GET /actuator/health` - 애플리케이션 상태 확인

## 6. 인프라 현대화 단계

### Phase 1: 레거시 모놀리식 (현재)
- 단일 Spring Boot 애플리케이션
- H2 인메모리 데이터베이스
- EC2 단일 인스턴스 배포
- 수동 배포

### Phase 2: 데이터베이스 현대화
- H2 → MySQL 전환
- EC2 MySQL → Amazon RDS for MySQL
- 커넥션 풀 최적화
- 백업/복구 자동화

### Phase 3: 컨테이너화
- Dockerfile 작성
- Docker Compose 로컬 환경
- Amazon ECR 이미지 저장소
- Amazon ECS (Fargate) 배포
- Application Load Balancer 연결

### Phase 4: 마이크로서비스 분리
- Product Service 분리
- Order Service 분리
- User Service 분리
- 서비스간 REST API 통신
- API Gateway 또는 ALB 라우팅

### Phase 5: AWS Managed Services 통합
- 이미지 저장: Amazon S3
- 캐싱: Amazon ElastiCache (Redis)
- 비동기 처리: Amazon SQS/SNS
- 로깅: CloudWatch Logs
- 모니터링: CloudWatch + X-Ray
- 시크릿 관리: AWS Secrets Manager

## 7. 개발 우선순위

### Sprint 1: 기본 기능 구현
1. 데이터 모델 및 엔티티 생성
2. 상품 CRUD API
3. 사용자 회원가입/로그인
4. 기본 예외 처리

### Sprint 2: 주문 기능 구현
1. 주문 생성 API
2. 재고 관리 로직
3. 주문 조회 API
4. 트랜잭션 처리

### Sprint 3: 사용자 기능 완성
1. 사용자 정보 수정
2. 비밀번호 변경

### Sprint 4: 장바구니 기능 구현
1. 장바구니 관리 API
2. 장바구니 기반 주문 생성
3. 책임 분리 (Cart ↔ Order)

### Sprint 5: 인프라 준비
1. Dockerfile 작성
2. Docker Compose 설정
3. 환경별 설정 분리
4. DB 초기화 스크립트

## 8. 제약사항 및 가정

### 8.1 제약사항
- 결제 기능은 구현하지 않음 (주문 생성까지만)
- 배송 추적 기능은 구현하지 않음 (SHIPPED, DELIVERED 상태 제외)
- 관리자 기능은 최소화
- 이미지 업로드는 URL만 저장 (실제 파일 업로드는 Phase 5에서)
- 비밀번호는 평문 저장 (데모 목적)
- 인증은 간단한 헤더 기반 (X-User-Id)

### 8.2 가정
- 모든 가격은 원화(KRW) 기준
- 세금 계산은 하지 않음
- 배송비는 무료
- 재고는 단순 정수 카운트
- 동시성 제어는 기본 수준 (낙관적 락)
- 사용자당 장바구니 1개
