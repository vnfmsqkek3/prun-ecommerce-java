# E-Commerce Demo Backend - Project Overview

## 📋 프로젝트 개요

### 목적
- 인프라 레벨 현대화 시연을 위한 데모 이커머스 백엔드 API
- Monolithic → Microservices 아키텍처 전환 과정 시연
- EC2 기반 → Container 기반(ECS) 전환 과정 시연
- Self-managed → AWS Managed Services 전환 과정 시연

### 프로젝트 특성
- RESTful API 제공
- 데모 목적 (간단한 인증, 평문 비밀번호)
- 명확한 도메인 분리 (상품, 사용자, 주문, 장바구니)
- 트랜잭션 기반 데이터 일관성 보장

## 🛠 기술 스택

### 필수 기술
- **Language**: Java 17
- **Framework**: Spring Boot 4.0.0
- **Build Tool**: Gradle 8.14
- **ORM**: Spring Data JPA
- **Database**: 
  - Local: H2 (In-memory)
  - Dev: MySQL
  - Prod: Amazon RDS for MySQL

### 주요 의존성
- spring-boot-starter-webmvc
- spring-boot-starter-data-jpa
- spring-boot-starter-validation
- spring-boot-starter-actuator
- h2database (runtime)
- mysql-connector-j (runtime)

## 🎯 구현할 주요 기능

### 1. 상품 관리 (Product)
- 상품 등록 (이름, 설명, 가격, 재고, 카테고리, 이미지 URL)
- 상품 목록 조회 (페이징, 카테고리 필터)
- 상품 상세 조회
- 상품 수정
- 상품 삭제 (Soft Delete)

**비즈니스 로직**:
- 상품명 중복 불가
- 재고 관리 (주문 시 차감, 취소 시 복구)
- 삭제된 상품은 조회 불가

### 2. 사용자 관리 (User)
- 회원가입 (이메일, 비밀번호, 이름, 전화번호)
- 로그인 (이메일, 비밀번호)
- 내 정보 조회
- 내 정보 수정 (이름, 전화번호만)
- 비밀번호 변경

**비즈니스 로직**:
- 이메일 중복 불가
- 이메일은 수정 불가 (로그인 ID)
- 비밀번호는 평문 저장 (데모 목적)
- 간단한 인증 (X-User-Id 헤더)

### 3. 주문 관리 (Order)
- 주문 생성 (직접 상품 선택)
- 장바구니 기반 주문 생성
- 주문 목록 조회 (페이징, 상태 필터)
- 주문 상세 조회
- 주문 상태 변경
- 주문 취소

**비즈니스 로직**:
- 주문 생성 시 재고 자동 차감
- 재고 부족 시 전체 주문 실패 (All or Nothing)
- OrderItem에 주문 시점의 상품명/가격 저장
- 주문 취소 시 재고 자동 복구
- PENDING 상태만 취소 가능
- 주문 상태: PENDING, CONFIRMED, CANCELLED

### 4. 장바구니 관리 (Cart)
- 장바구니에 상품 추가
- 장바구니 조회
- 장바구니 상품 수량 변경
- 장바구니 상품 삭제
- 장바구니 전체 비우기

**비즈니스 로직**:
- 사용자당 장바구니 1개
- 중복 상품 추가 시 수량 자동 증가
- 장바구니 조회 시 실시간 상품 정보 반영
- 장바구니 기반 주문 생성 시 자동 비우기

## 📊 데이터 모델

### Entity 구조

**Product** (상품)
- id, name, description, price, stockQuantity, category, imageUrl, deleted
- createdAt, updatedAt

**User** (사용자)
- id, email, password, name, phoneNumber
- createdAt, updatedAt

**Order** (주문)
- id, userId, status, totalAmount
- createdAt, updatedAt
- OneToMany: orderItems

**OrderItem** (주문 상품)
- id, orderId, productId, productName, price, quantity
- ManyToOne: order

**Cart** (장바구니)
- id, userId
- createdAt, updatedAt
- OneToMany: cartItems

**CartItem** (장바구니 상품)
- id, cartId, productId, quantity
- ManyToOne: cart

### Enum

**ProductCategory**
- ELECTRONICS (전자제품)
- CLOTHING (의류)
- FOOD (식품)
- BOOK (도서)
- HOME (생활용품)

**OrderStatus**
- PENDING (대기중)
- CONFIRMED (확인됨)
- CANCELLED (취소됨)

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

## 📝 개발 우선순위

### Sprint 0: 프로젝트 초기 설정
- Spring Boot 프로젝트 생성
- Gradle 설정
- 기본 의존성 추가
- 문서 작성

### Sprint 1: 기본 기능 구현
- BaseEntity, GlobalExceptionHandler 등 공통 설정
- Entity 생성 (Product, User, Order, OrderItem)
- Repository 생성
- 상품 관리 API (5개)
- 사용자 관리 API (3개: 회원가입, 로그인, 내 정보 조회)

### Sprint 2: 주문 기능 구현
- 주문 생성 API (재고 관리)
- 주문 목록/상세 조회 API
- 주문 상태 변경 API
- 주문 취소 API (재고 복구)

### Sprint 3: 사용자 기능 완성
- 사용자 정보 수정 API
- 비밀번호 변경 API

### Sprint 4: 장바구니 기능 구현
- Cart, CartItem Entity 생성
- 장바구니 관리 API (5개)
- 장바구니 기반 주문 생성 API

### Sprint 5: 인프라 준비
- 환경별 설정 분리 (local, dev, prod)
- DB 초기화 스크립트 (schema.sql, data.sql)
- Dockerfile 작성
- Docker Compose 설정

## 🎨 아키텍처 패턴

### Layered Architecture
```
Controller (REST API)
    ↓
Service (Business Logic)
    ↓
Repository (Data Access)
    ↓
Entity (Domain Model)
```

### 책임 분리
- **Controller**: HTTP 요청/응답 처리, DTO만 사용
- **Service**: 비즈니스 로직, 트랜잭션 관리, Entity ↔ DTO 변환
- **Repository**: 데이터 접근, JPA 쿼리
- **Entity**: 도메인 모델, 비즈니스 메서드 포함
- **DTO**: 계층 간 데이터 전달, Validation 포함

### 예외 처리
- BusinessException (비즈니스 예외)
- ErrorCode Enum (에러 코드 정의)
- GlobalExceptionHandler (통일된 에러 응답)

## 🔐 인증 및 보안

### 인증 방식
- 간단한 헤더 기반 인증 (X-User-Id)
- 로그인 시 userId 반환
- 이후 요청에 헤더로 전달

### 보안 고려사항
- 비밀번호 평문 저장 (데모 목적, 실제 운영에서는 BCrypt 사용)
- SQL Injection 방지 (JPA 사용)
- XSS 방지 (Spring 기본 제공)

## 📦 API 응답 형식

### 성공 응답
```json
// 단건 조회
{
  "id": 1,
  "name": "상품명",
  ...
}

// 목록 조회 (페이징)
{
  "content": [...],
  "totalElements": 10,
  "totalPages": 1,
  "number": 0,
  "size": 20
}
```

### 에러 응답
```json
{
  "code": "PRODUCT_NOT_FOUND",
  "message": "상품을 찾을 수 없습니다",
  "status": 404,
  "timestamp": "2025-12-10T10:00:00"
}
```

## 🧪 테스트 방법

### HTTP Client 사용
- IntelliJ IDEA 또는 VS Code의 REST Client
- `api-tests/` 디렉토리에 `.http` 파일 작성
- 각 도메인별 파일 분리 (product.http, user.http 등)

### 테스트 시나리오
1. 회원가입 → 로그인
2. 상품 등록 → 조회
3. 장바구니 담기 → 주문 생성
4. 주문 취소 → 재고 복구 확인

## 🌍 환경 설정

### Local (기본)
- H2 인메모리 데이터베이스
- DDL auto: create-drop
- 상세 로깅

### Dev
- MySQL 데이터베이스
- DDL auto: update
- 커넥션 풀: 10개

### Prod
- Amazon RDS MySQL
- DDL auto: validate
- 환경 변수로 DB 정보 주입
- 커넥션 풀: 20개

## 📌 제약사항 및 가정

### 제약사항
- 결제 기능 없음 (주문 생성까지만)
- 배송 추적 없음 (SHIPPED, DELIVERED 상태 제외)
- 관리자 기능 최소화
- 이미지 업로드 없음 (URL만 저장)

### 가정
- 모든 가격은 원화(KRW)
- 세금 계산 없음
- 배송비 무료
- 재고는 단순 정수 카운트
- 동시성 제어는 기본 수준

## 🎓 참고 원칙

### Clean Code
- 의미 있는 이름 사용
- 함수는 한 가지 일만
- 작게 유지 (20줄 이내 권장)
- 예외를 사용하여 오류 처리

### Effective Java
- 불변성 최대화 (Setter 사용 금지)
- Builder 패턴 사용
- null 대신 빈 컬렉션 반환
- 실패 원자적으로 만들기 (트랜잭션)

## 🔗 관련 문서

- `REQUIREMENTS.md`: 상세 요구사항 명세 (AI Agent가 생성)
- `DEVELOPMENT_RULES.md`: 개발 규칙
- `PLAN.md`: Sprint별 작업 계획 (AI Agent가 생성)
- `README.md`: 프로젝트 실행 가이드
