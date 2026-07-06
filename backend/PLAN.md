# 프로젝트 작업 계획 (Project Plan)

## 진행 상황 요약

| Sprint | 상태 | 진행률 | 시작일 | 완료일 |
|--------|------|--------|--------|--------|
| Sprint 0 | ✅ 완료 | 100% | 2025-12-09 | 2025-12-09 |
| Sprint 1 | ✅ 완료 | 100% | 2025-12-10 | 2025-12-10 |
| Sprint 2 | ✅ 완료 | 100% | 2025-12-10 | 2025-12-10 |
| Sprint 3 | ✅ 완료 | 100% | 2025-12-10 | 2025-12-10 |
| Sprint 4 | ✅ 완료 | 100% | 2025-12-10 | 2025-12-10 |
| Sprint 5 | 📋 대기 | 0% | - | - |

---

## Sprint 0: 프로젝트 초기 설정 ✅

### 목표
프로젝트 기본 구조 및 문서 작성

### 작업 항목

#### 1. 프로젝트 초기화 ✅
- [x] Spring Boot 프로젝트 생성
- [x] Gradle 설정 (8.14)
- [x] 기본 의존성 추가
- [x] 프로젝트 빌드 확인

#### 2. 문서 작성 ✅
- [x] 요구사항 명세서 작성 (REQUIREMENTS.md)
- [x] 요구사항 명세서 영문 버전 (REQUIREMENTS_EN.md)
- [x] 개발 규칙 문서 작성 (DEVELOPMENT_RULES.md)
- [x] 개발 규칙 영문 버전 (DEVELOPMENT_RULES_EN.md)
- [x] 작업 계획 문서 작성 (PLAN.md)

#### 3. Git 설정 ✅
- [x] Git 저장소 초기화
- [x] 초기 커밋 생성

### 완료 기준
- [x] 프로젝트 빌드 성공
- [x] 모든 문서 작성 완료
- [x] Git 커밋 완료

---

## Sprint 1: 기본 기능 구현 ✅

### 목표
Entity, Repository 구성 및 상품 관리 API 구현

### 작업 항목

#### 1. 공통 설정 및 기반 구조
- [x] BaseEntity 생성
  - [x] createdAt, updatedAt 필드
  - [x] JPA Auditing 설정
- [x] GlobalExceptionHandler 생성
  - [x] BusinessException 정의
  - [x] ErrorResponse DTO 정의
  - [x] 공통 예외 처리 로직
- [x] application.properties 설정
  - [x] H2 데이터베이스 설정
  - [x] JPA 설정
  - [x] 로깅 설정

#### 2. Entity 생성
- [x] Product Entity
  - [x] 필드: id, name, description, price, stockQuantity, category, imageUrl, deleted
  - [x] Builder 패턴 적용
  - [x] 비즈니스 메서드 (decreaseStock, updateInfo)
- [x] User Entity
  - [x] 필드: id, email, password, name, phoneNumber
  - [x] Builder 패턴 적용
- [x] Order Entity
  - [x] 필드: id, userId, status, totalAmount
  - [x] OrderStatus Enum 정의
  - [x] Builder 패턴 적용
- [x] OrderItem Entity
  - [x] 필드: id, orderId, productId, productName, price, quantity
  - [x] Builder 패턴 적용

#### 3. Repository 생성
- [x] ProductRepository
  - [x] existsByName 메서드
  - [x] findByDeletedFalse 메서드
- [x] UserRepository
  - [x] findByEmail 메서드
  - [x] existsByEmail 메서드
- [x] OrderRepository
  - [x] findByUserId 메서드
- [x] OrderItemRepository

#### 4. 상품 관리 API 구현

##### 4.1 상품 등록 (POST /api/products)
- [x] ProductCreateDto 작성
  - [x] 필드: name, description, price, stockQuantity, category, imageUrl
  - [x] Validation 어노테이션 추가
- [x] ProductDto 작성 (응답용)
  - [x] 필드: id, name, description, price, stockQuantity, category, imageUrl, createdAt, updatedAt
  - [x] from() 정적 메서드
- [x] ProductService.insertProduct 구현
  - [x] 상품명 중복 검증
  - [x] Product Entity 생성 및 저장
  - [x] ProductDto 변환 및 반환
- [x] ProductController.insertProduct 구현
  - [x] @Valid 검증
  - [x] Service 호출
- [x] HTTP Client 파일 작성 (product.http)
- [x] 테스트 실행 및 검증

##### 4.2 상품 목록 조회 (GET /api/products)
- [x] ProductService.selectProductList 구현
  - [x] 페이징 처리
  - [x] 삭제되지 않은 상품만 조회
  - [x] ProductDto 변환
- [x] ProductController.selectProductList 구현
  - [x] Pageable 파라미터
- [x] HTTP Client 파일 업데이트
- [x] 테스트 실행 및 검증

##### 4.3 상품 상세 조회 (GET /api/products/{id})
- [x] ProductNotFoundException 정의
- [x] ProductService.selectProduct 구현
  - [x] ID로 상품 조회
  - [x] 존재하지 않으면 예외 발생
  - [x] ProductDto 변환
- [x] ProductController.selectProduct 구현
- [x] HTTP Client 파일 업데이트
- [x] 테스트 실행 및 검증

##### 4.4 상품 수정 (PUT /api/products/{id})
- [x] ProductUpdateDto 작성
  - [x] 필드: name, description, price, stockQuantity, category, imageUrl
  - [x] Validation 어노테이션
- [x] ProductService.updateProduct 구현
  - [x] 상품 존재 확인
  - [x] 상품명 중복 검증 (자신 제외)
  - [x] Entity 업데이트
  - [x] ProductDto 변환
- [x] ProductController.updateProduct 구현
- [x] HTTP Client 파일 업데이트
- [x] 테스트 실행 및 검증

##### 4.5 상품 삭제 (DELETE /api/products/{id})
- [x] ProductService.deleteProduct 구현
  - [x] 상품 존재 확인
  - [x] Soft Delete 처리 (deleted = true)
- [x] ProductController.deleteProduct 구현
- [x] HTTP Client 파일 업데이트
- [x] 테스트 실행 및 검증

#### 5. 사용자 관리 API 구현

##### 5.1 회원가입 (POST /api/users/signup)
- [x] UserSignupDto 작성
  - [x] 필드: email, password, name, phoneNumber
  - [x] Validation 어노테이션
- [x] UserDto 작성 (응답용)
  - [x] 필드: id, email, name, phoneNumber, createdAt
  - [x] from() 정적 메서드
- [x] UserService.signup 구현
  - [x] 이메일 중복 검증
  - [x] 비밀번호 암호화 (BCrypt) → 평문 저장으로 변경
  - [x] User Entity 생성 및 저장
  - [x] UserDto 변환
- [x] UserController.signup 구현
- [x] HTTP Client 파일 작성 (user.http)
- [x] 테스트 실행 및 검증

##### 5.2 로그인 (POST /api/users/login)
- [x] UserLoginDto 작성
  - [x] 필드: email, password
- [x] LoginResponse 작성
  - [x] 필드: token (또는 sessionId), user
- [x] UserService.login 구현
  - [x] 이메일로 사용자 조회
  - [x] 비밀번호 검증
  - [x] 토큰/세션 생성 (간단한 방식)
- [x] UserController.login 구현
- [x] HTTP Client 파일 업데이트
- [x] 테스트 실행 및 검증

##### 5.3 내 정보 조회 (GET /api/users/me)
- [x] 간단한 인증 처리 구현 (헤더에서 userId 추출)
- [x] UserService.selectUser 구현
- [x] UserController.selectUser 구현
- [x] HTTP Client 파일 업데이트
- [x] 테스트 실행 및 검증

### 완료 기준
- [x] 모든 Entity 및 Repository 생성 완료
- [x] 상품 관리 5개 API 구현 및 테스트 완료
- [x] 사용자 관리 3개 API 구현 및 테스트 완료
- [x] HTTP Client로 모든 API 정상 작동 확인
- [x] Gradle 빌드 성공
- [x] Git 커밋 완료

---

## Sprint 2: 주문 기능 구현 ✅

### 목표
주문 생성 및 조회 API 구현, 재고 관리 로직 추가

### 작업 항목

#### 1. 주문 생성 (POST /api/orders)
- [x] OrderItemDto 작성
  - [x] 필드: productId, quantity
- [x] OrderCreateDto 작성
  - [x] 필드: userId, items (List<OrderItemDto>)
  - [x] Validation 어노테이션
- [x] OrderDto 작성 (응답용)
  - [x] 필드: id, userId, status, totalAmount, items, createdAt
  - [x] from() 정적 메서드
- [x] InsufficientStockException 정의
- [x] OrderService.insertOrder 구현
  - [x] 상품 존재 및 재고 확인
  - [x] 재고 차감 (Product.decreaseStock)
  - [x] 주문 총액 계산
  - [x] Order 및 OrderItem 생성
  - [x] 트랜잭션 처리
- [x] OrderController.insertOrder 구현
- [x] HTTP Client 파일 작성 (order.http)
- [x] 테스트 실행 및 검증

#### 2. 주문 목록 조회 (GET /api/orders)
- [x] OrderService.selectOrderList 구현
  - [x] userId로 주문 목록 조회
  - [x] 페이징 처리
  - [x] OrderDto 변환
- [x] OrderController.selectOrderList 구현
- [x] HTTP Client 파일 업데이트
- [x] 테스트 실행 및 검증

#### 3. 주문 상세 조회 (GET /api/orders/{id})
- [x] OrderNotFoundException 정의
- [x] OrderService.selectOrder 구현
  - [x] 주문 조회 (OrderItem 포함)
  - [x] 본인 주문 확인
  - [x] OrderDto 변환
- [x] OrderController.selectOrder 구현
- [x] HTTP Client 파일 업데이트
- [x] 테스트 실행 및 검증

#### 4. 주문 상태 변경 (PATCH /api/orders/{id}/status)
- [x] OrderStatusUpdateDto 작성
  - [x] 필드: status
- [x] InvalidOrderStatusException 정의
- [x] OrderService.updateOrderStatus 구현
  - [x] 주문 존재 확인
  - [x] 상태 전이 검증
  - [x] 상태 업데이트
- [x] OrderController.updateOrderStatus 구현
- [x] HTTP Client 파일 업데이트
- [x] 테스트 실행 및 검증

#### 5. 주문 취소 (POST /api/orders/{id}/cancel)
- [x] OrderService.cancelOrder 구현
  - [x] 주문 존재 확인
  - [x] PENDING 상태 확인
  - [x] 재고 복구
  - [x] 상태를 CANCELLED로 변경
  - [x] 트랜잭션 처리
- [x] OrderController.cancelOrder 구현
- [x] HTTP Client 파일 업데이트
- [x] 테스트 실행 및 검증

### 완료 기준
- [x] 주문 관리 5개 API 구현 및 테스트 완료
- [x] 재고 관리 로직 정상 작동 확인
- [x] 트랜잭션 처리 확인
- [x] HTTP Client로 모든 API 정상 작동 확인
- [x] Gradle 빌드 성공
- [x] Git 커밋 완료

---

## Sprint 3: 완성도 향상 ✅

### 목표
사용자 정보 수정 및 비밀번호 변경 기능 추가

### 작업 항목

#### 1. 사용자 정보 수정 기능 추가
- [x] UserUpdateDto 작성
  - [x] 필드: name, phoneNumber
  - [x] Validation 어노테이션
- [x] UserService.updateUser 구현
  - [x] 사용자 존재 확인
  - [x] 정보 업데이트
  - [x] UserDto 변환
- [x] UserController.updateUser 구현
  - [x] PUT /api/users/me 엔드포인트
  - [x] X-User-Id 헤더로 사용자 식별
- [x] HTTP Client 파일 업데이트
- [x] 테스트 실행 및 검증

#### 2. 비밀번호 변경 기능 추가
- [x] PasswordChangeDto 작성
  - [x] 필드: currentPassword, newPassword
  - [x] Validation 어노테이션
- [x] UserService.changePassword 구현
  - [x] 사용자 존재 확인
  - [x] 현재 비밀번호 일치 확인
  - [x] 새 비밀번호로 변경
- [x] UserController.changePassword 구현
  - [x] PUT /api/users/me/password 엔드포인트
  - [x] X-User-Id 헤더로 사용자 식별
- [x] HTTP Client 파일 업데이트
- [x] 테스트 실행 및 검증

### 완료 기준
- [x] 사용자 정보 수정 API 구현 및 테스트 완료
- [x] 비밀번호 변경 API 구현 및 테스트 완료
- [x] HTTP Client로 모든 API 정상 작동 확인
- [x] Gradle 빌드 성공
- [x] Git 커밋 완료

---

## Sprint 4: 장바구니 기능 구현 ✅

### 목표
장바구니 관리 및 장바구니 기반 주문 생성 기능 추가

### 작업 항목

#### 1. Entity 생성
- [x] Cart Entity
  - [x] 필드: id, userId, createdAt, updatedAt
  - [x] 사용자당 하나의 장바구니
- [x] CartItem Entity
  - [x] 필드: id, cartId, productId, quantity
  - [x] Cart와 연관관계 설정

#### 2. Repository 생성
- [x] CartRepository
  - [x] findByUserId 메서드
- [x] CartItemRepository
  - [x] findByCartIdAndProductId 메서드
  - [x] deleteByCartId 메서드

#### 3. 장바구니 DTO 작성
- [x] CartItemAddDto 작성
  - [x] 필드: productId, quantity
  - [x] Validation 어노테이션
- [x] CartItemUpdateDto 작성
  - [x] 필드: quantity (최소 1)
  - [x] Validation 어노테이션
- [x] CartItemDto 작성 (응답용)
  - [x] 필드: id, productId, productName, price, quantity
  - [x] from() 정적 메서드
- [x] CartDto 작성 (응답용)
  - [x] 필드: id, userId, items, createdAt, updatedAt
  - [x] from() 정적 메서드

#### 4. 장바구니 관리 API 구현

##### 4.1 장바구니에 상품 추가 (POST /api/carts/items)
- [x] CartService.addCartItem 구현
  - [x] 사용자의 장바구니 조회 (없으면 생성)
  - [x] 상품 존재 확인
  - [x] 이미 있는 상품이면 수량 증가
  - [x] 없는 상품이면 새로 추가
- [x] CartController.addCartItem 구현
- [x] HTTP Client 파일 작성 (cart.http)
- [x] 테스트 실행 및 검증

##### 4.2 장바구니 조회 (GET /api/carts)
- [x] CartService.selectCart 구현
  - [x] 사용자의 장바구니 조회
  - [x] CartItem과 Product 정보 조인
  - [x] CartDto 변환 (상품명, 가격 포함)
- [x] CartController.selectCart 구현
- [x] HTTP Client 파일 업데이트
- [x] 테스트 실행 및 검증

##### 4.3 장바구니 상품 수량 변경 (PUT /api/carts/items/{cartItemId})
- [x] CartService.updateCartItemQuantity 구현
  - [x] CartItem 존재 확인
  - [x] 수량 변경 (최소 1)
- [x] CartController.updateCartItemQuantity 구현
- [x] HTTP Client 파일 업데이트
- [x] 테스트 실행 및 검증

##### 4.4 장바구니 상품 삭제 (DELETE /api/carts/items/{cartItemId})
- [x] CartService.deleteCartItem 구현
  - [x] CartItem 존재 확인
  - [x] CartItem 삭제
- [x] CartController.deleteCartItem 구현
- [x] HTTP Client 파일 업데이트
- [x] 테스트 실행 및 검증

##### 4.5 장바구니 전체 비우기 (DELETE /api/carts)
- [x] CartService.clearCart 구현
  - [x] 사용자의 모든 CartItem 삭제
- [x] CartController.clearCart 구현
- [x] HTTP Client 파일 업데이트
- [x] 테스트 실행 및 검증

#### 5. 장바구니 기반 주문 생성

##### 5.1 장바구니에서 주문 생성 (POST /api/orders/from-cart)
- [x] OrderService.insertOrderFromCart 구현
  - [x] 장바구니 조회
  - [x] 장바구니가 비어있으면 에러
  - [x] OrderCreateDto 형식으로 변환
  - [x] 기존 insertOrder 로직 재사용
  - [x] 주문 생성 성공 시 장바구니 비우기
  - [x] 트랜잭션 처리
- [x] OrderController.insertOrderFromCart 구현
- [x] HTTP Client 파일 업데이트 (order.http)
- [x] 테스트 실행 및 검증

### 완료 기준
- [x] Cart, CartItem Entity 생성 완료
- [x] 장바구니 관리 5개 API 구현 및 테스트 완료
- [x] 장바구니 기반 주문 생성 API 구현 및 테스트 완료
- [x] HTTP Client로 모든 API 정상 작동 확인
- [x] Gradle 빌드 성공
- [x] Git 커밋 완료

---

## Sprint 5: 인프라 준비 📋

### 목표
컨테이너화 준비 및 운영 환경 설정

### 작업 항목

#### 1. 환경 설정 분리
- [ ] application-local.properties 생성 (H2)
- [ ] application-dev.properties 생성 (MySQL)
- [ ] application-prod.properties 생성 (MySQL)
- [ ] 환경별 설정 분리

#### 2. MySQL 연동 준비
- [ ] MySQL 의존성 추가
- [ ] MySQL 연결 설정
- [ ] 로컬 MySQL 테스트

#### 3. Dockerfile 작성
- [ ] Multi-stage build Dockerfile 작성
- [ ] .dockerignore 파일 작성
- [ ] Docker 이미지 빌드 테스트

#### 4. Docker Compose 작성
- [ ] docker-compose.yml 작성
  - [ ] Spring Boot 애플리케이션
  - [ ] MySQL 컨테이너
  - [ ] 네트워크 설정
  - [ ] 볼륨 설정
- [ ] Docker Compose 실행 테스트

#### 5. 헬스 체크 엔드포인트
- [ ] Spring Boot Actuator 설정
- [ ] /actuator/health 엔드포인트 확인
- [ ] 커스텀 헬스 체크 추가 (DB 연결 확인)

#### 6. 로깅 설정 개선
- [ ] logback-spring.xml 작성
- [ ] 환경별 로그 레벨 설정
- [ ] 로그 파일 출력 설정

#### 7. 문서화
- [ ] README.md 작성
  - [ ] 프로젝트 소개
  - [ ] 실행 방법
  - [ ] API 문서
  - [ ] 환경 설정 가이드
- [ ] API 문서 작성 (Swagger 또는 수동)

### 완료 기준
- [ ] 환경별 설정 분리 완료
- [ ] MySQL 연동 성공
- [ ] Docker 이미지 빌드 성공
- [ ] Docker Compose 실행 성공
- [ ] 헬스 체크 정상 작동
- [ ] 문서화 완료
- [ ] Git 커밋 완료

---

## 다음 단계 (Phase 2~5)

### Phase 2: 데이터베이스 현대화
- EC2 MySQL → Amazon RDS for MySQL 마이그레이션
- 커넥션 풀 최적화
- RDS 백업/복구 설정

### Phase 3: 컨테이너화
- Amazon ECR 이미지 푸시
- Amazon ECS (Fargate) 배포
- Application Load Balancer 설정

### Phase 4: 마이크로서비스 분리
- Product Service 분리
- Order Service 분리
- User Service 분리
- 서비스간 통신 구현

### Phase 5: AWS Managed Services 통합
- Amazon S3 (이미지 저장)
- Amazon ElastiCache (캐싱)
- Amazon SQS/SNS (비동기 처리)
- CloudWatch (로깅/모니터링)
- AWS Secrets Manager (시크릿 관리)

---

## 진행 상황 업데이트 규칙

1. 작업 시작 시: 상태를 ⏳ 진행중으로 변경
2. 작업 완료 시: 체크박스 체크 및 상태를 ✅ 완료로 변경
3. 각 Sprint 완료 시: 완료일 기록
4. 커밋 시: 관련 작업 항목 체크

## 범례

- ✅ 완료
- ⏳ 진행중
- 📋 대기
- ❌ 취소/보류
- [ ] 미완료 작업
- [x] 완료된 작업
