# E-Commerce Demo - Backend API Documentation

> 프론트엔드 개발을 위한 백엔드 API 명세서

## 📋 프로젝트 개요

이 문서는 E-Commerce Demo 백엔드 API에 대한 명세를 제공합니다.
프론트엔드 개발 시 이 문서를 참조하여 API를 호출하세요.

### 백엔드 정보
- **Base URL**: `http://localhost:8080`
- **Framework**: Spring Boot 4.0.0
- **Database**: H2 (로컬), MySQL (개발/운영)
- **인증 방식**: X-User-Id 헤더 (간단한 데모용)

## 🔐 인증

모든 인증이 필요한 API는 요청 헤더에 `X-User-Id`를 포함해야 합니다.

```http
X-User-Id: 1
```

로그인 API 응답에서 `userId`를 받아 이후 요청에 사용하세요.

## 📚 API 엔드포인트

### 1. 상품 API

#### 1.1 상품 등록
```http
POST /api/products
Content-Type: application/json

{
  "name": "노트북",
  "description": "고성능 노트북",
  "price": 1500000,
  "stockQuantity": 10,
  "category": "ELECTRONICS",
  "imageUrl": "https://example.com/laptop.jpg"
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "name": "노트북",
  "description": "고성능 노트북",
  "price": 1500000,
  "stockQuantity": 10,
  "category": "ELECTRONICS",
  "imageUrl": "https://example.com/laptop.jpg",
  "createdAt": "2025-12-10T10:00:00",
  "updatedAt": "2025-12-10T10:00:00"
}
```

#### 1.2 상품 목록 조회
```http
GET /api/products?page=0&size=20&category=ELECTRONICS
```

**Query Parameters:**
- `page`: 페이지 번호 (기본값: 0)
- `size`: 페이지 크기 (기본값: 20)
- `category`: 카테고리 필터 (선택, ELECTRONICS/CLOTHING/FOOD/BOOK/HOME)

**Response (200 OK):**
```json
{
  "content": [
    {
      "id": 1,
      "name": "노트북",
      "price": 1500000,
      "stockQuantity": 10,
      "category": "ELECTRONICS",
      ...
    }
  ],
  "totalElements": 10,
  "totalPages": 1,
  "number": 0,
  "size": 20
}
```

#### 1.3 상품 상세 조회
```http
GET /api/products/{id}
```

**Response (200 OK):** 상품 상세 정보

#### 1.4 상품 수정
```http
PUT /api/products/{id}
Content-Type: application/json

{
  "name": "노트북",
  "description": "고성능 게이밍 노트북",
  "price": 1800000,
  "stockQuantity": 8,
  "category": "ELECTRONICS",
  "imageUrl": "https://example.com/laptop.jpg"
}
```

**Response (200 OK):** 수정된 상품 정보

#### 1.5 상품 삭제
```http
DELETE /api/products/{id}
```

**Response (204 No Content)**

---

### 2. 사용자 API

#### 2.1 회원가입
```http
POST /api/users/signup
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "name": "홍길동",
  "phoneNumber": "010-1234-5678"
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "name": "홍길동",
  "phoneNumber": "010-1234-5678",
  "createdAt": "2025-12-10T10:00:00"
}
```

#### 2.2 로그인
```http
POST /api/users/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200 OK):**
```json
{
  "userId": 1,
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "홍길동",
    "phoneNumber": "010-1234-5678",
    "createdAt": "2025-12-10T10:00:00"
  },
  "message": "로그인 성공"
}
```

**중요:** `userId`를 저장하여 이후 요청의 `X-User-Id` 헤더에 사용하세요.

#### 2.3 내 정보 조회
```http
GET /api/users/me
X-User-Id: 1
```

**Response (200 OK):** 사용자 정보

#### 2.4 내 정보 수정
```http
PUT /api/users/me
X-User-Id: 1
Content-Type: application/json

{
  "name": "홍길동(수정)",
  "phoneNumber": "010-9999-9999"
}
```

**Response (200 OK):** 수정된 사용자 정보

**참고:** 이메일은 수정 불가능합니다.

#### 2.5 비밀번호 변경
```http
PUT /api/users/me/password
X-User-Id: 1
Content-Type: application/json

{
  "currentPassword": "password123",
  "newPassword": "newpassword123"
}
```

**Response (204 No Content)**

---

### 3. 장바구니 API

#### 3.1 장바구니에 상품 추가
```http
POST /api/carts/items
X-User-Id: 1
Content-Type: application/json

{
  "productId": 1,
  "quantity": 2
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "userId": 1,
  "items": [
    {
      "id": 1,
      "productId": 1,
      "productName": "노트북",
      "price": 1500000,
      "quantity": 2
    }
  ],
  "createdAt": "2025-12-10T10:00:00",
  "updatedAt": "2025-12-10T10:00:00"
}
```

**참고:** 이미 장바구니에 있는 상품을 추가하면 수량이 증가합니다.

#### 3.2 장바구니 조회
```http
GET /api/carts
X-User-Id: 1
```

**Response (200 OK):**
```json
{
  "id": 1,
  "userId": 1,
  "items": [
    {
      "id": 1,
      "productId": 1,
      "productName": "노트북",
      "price": 1500000,
      "quantity": 2
    }
  ],
  "createdAt": "2025-12-10T10:00:00",
  "updatedAt": "2025-12-10T10:00:00"
}
```

**참고:** 상품 정보(이름, 가격)는 실시간으로 조회됩니다.

#### 3.3 장바구니 상품 수량 변경
```http
PUT /api/carts/items/{cartItemId}
X-User-Id: 1
Content-Type: application/json

{
  "quantity": 5
}
```

**Response (200 OK):** 업데이트된 장바구니 정보

**참고:** 수량은 최소 1 이상이어야 합니다.

#### 3.4 장바구니 상품 삭제
```http
DELETE /api/carts/items/{cartItemId}
X-User-Id: 1
```

**Response (204 No Content)**

#### 3.5 장바구니 전체 비우기
```http
DELETE /api/carts
X-User-Id: 1
```

**Response (204 No Content)**

---

### 4. 주문 API

#### 4.1 주문 생성 (직접)
```http
POST /api/orders
Content-Type: application/json

{
  "userId": 1,
  "items": [
    {
      "productId": 1,
      "quantity": 2
    },
    {
      "productId": 2,
      "quantity": 1
    }
  ]
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "userId": 1,
  "status": "PENDING",
  "totalAmount": 3030000,
  "items": [
    {
      "id": 1,
      "productId": 1,
      "productName": "노트북",
      "price": 1500000,
      "quantity": 2
    },
    {
      "id": 2,
      "productId": 2,
      "productName": "마우스",
      "price": 30000,
      "quantity": 1
    }
  ],
  "createdAt": "2025-12-10T10:00:00",
  "updatedAt": "2025-12-10T10:00:00"
}
```

**참고:** 
- 주문 생성 시 재고가 자동으로 차감됩니다
- OrderItem에는 주문 시점의 상품명과 가격이 저장됩니다

#### 4.2 장바구니 기반 주문 생성
```http
POST /api/orders/from-cart
X-User-Id: 1
```

**Response (201 Created):** 생성된 주문 정보

**참고:** 
- 장바구니 내용으로 주문이 생성됩니다
- 주문 성공 시 장바구니가 자동으로 비워집니다

#### 4.3 주문 목록 조회
```http
GET /api/orders?userId=1&page=0&size=20&status=PENDING
```

**Query Parameters:**
- `userId`: 사용자 ID (필수)
- `page`: 페이지 번호 (기본값: 0)
- `size`: 페이지 크기 (기본값: 20)
- `status`: 주문 상태 필터 (선택, PENDING/CONFIRMED/CANCELLED)

**Response (200 OK):** 페이징된 주문 목록

#### 4.4 주문 상세 조회
```http
GET /api/orders/{id}
```

**Response (200 OK):** 주문 상세 정보 (OrderItem 포함)

#### 4.5 주문 상태 변경
```http
PATCH /api/orders/{id}/status
Content-Type: application/json

{
  "status": "CONFIRMED"
}
```

**Response (200 OK):** 변경된 주문 정보

**주문 상태:**
- `PENDING`: 대기중
- `CONFIRMED`: 확인됨
- `CANCELLED`: 취소됨

**상태 전이 규칙:**
- PENDING → CONFIRMED (가능)
- PENDING → CANCELLED (가능)
- CONFIRMED → CANCELLED (불가능)

#### 4.6 주문 취소
```http
POST /api/orders/{id}/cancel
```

**Response (200 OK):** 취소된 주문 정보

**참고:** 
- PENDING 상태의 주문만 취소 가능
- 취소 시 재고가 자동으로 복구됩니다

---

## 🚨 에러 응답 형식

모든 에러는 다음 형식으로 반환됩니다:

```json
{
  "code": "PRODUCT_NOT_FOUND",
  "message": "상품을 찾을 수 없습니다",
  "status": 404,
  "timestamp": "2025-12-10T10:00:00"
}
```

### 주요 에러 코드

**상품 관련:**
- `PRODUCT_NOT_FOUND` (404): 상품을 찾을 수 없음
- `DUPLICATE_PRODUCT_NAME` (409): 중복된 상품명
- `INSUFFICIENT_STOCK` (400): 재고 부족

**사용자 관련:**
- `USER_NOT_FOUND` (404): 사용자를 찾을 수 없음
- `DUPLICATE_EMAIL` (409): 중복된 이메일
- `INVALID_CREDENTIALS` (401): 이메일 또는 비밀번호 불일치

**주문 관련:**
- `ORDER_NOT_FOUND` (404): 주문을 찾을 수 없음
- `INVALID_ORDER_STATUS` (400): 유효하지 않은 상태 전이
- `CANNOT_CANCEL_ORDER` (400): 취소할 수 없는 주문
- `EMPTY_ORDER_ITEMS` (400): 주문 상품이 없음

**장바구니 관련:**
- `CART_ITEM_NOT_FOUND` (404): 장바구니 상품을 찾을 수 없음
- `EMPTY_CART` (400): 장바구니가 비어있음

**공통:**
- `INVALID_INPUT` (400): 잘못된 입력 (Validation 실패)
- `INTERNAL_SERVER_ERROR` (500): 서버 오류

---

## 📊 데이터 모델

### Product (상품)
```typescript
interface Product {
  id: number;
  name: string;
  description?: string;
  price: number;
  stockQuantity: number;
  category: 'ELECTRONICS' | 'CLOTHING' | 'FOOD' | 'BOOK' | 'HOME';
  imageUrl?: string;
  createdAt: string;
  updatedAt: string;
}
```

### User (사용자)
```typescript
interface User {
  id: number;
  email: string;
  name: string;
  phoneNumber?: string;
  createdAt: string;
}
```

### Order (주문)
```typescript
interface Order {
  id: number;
  userId: number;
  status: 'PENDING' | 'CONFIRMED' | 'CANCELLED';
  totalAmount: number;
  items: OrderItem[];
  createdAt: string;
  updatedAt: string;
}

interface OrderItem {
  id: number;
  productId: number;
  productName: string;
  price: number;
  quantity: number;
}
```

### Cart (장바구니)
```typescript
interface Cart {
  id: number;
  userId: number;
  items: CartItem[];
  createdAt: string;
  updatedAt: string;
}

interface CartItem {
  id: number;
  productId: number;
  productName: string;  // 실시간 조회
  price: number;        // 실시간 조회
  quantity: number;
}
```

---

## 🔄 주요 비즈니스 로직

### 재고 관리
- 주문 생성 시 재고가 자동으로 차감됩니다
- 주문 취소 시 재고가 자동으로 복구됩니다
- 재고 부족 시 주문이 실패하며, 어떤 상품이 부족한지 에러 메시지에 포함됩니다

### 장바구니
- 사용자당 하나의 장바구니만 존재합니다
- 중복 상품 추가 시 수량이 자동으로 증가합니다
- 장바구니 조회 시 상품 정보(이름, 가격)는 실시간으로 조회됩니다
- 장바구니 기반 주문 생성 시 장바구니가 자동으로 비워집니다

### 주문
- OrderItem에는 주문 시점의 상품명과 가격이 저장됩니다
- 상품 가격이 변경되어도 기존 주문에는 영향이 없습니다
- PENDING 상태의 주문만 취소 가능합니다

### 사용자
- 이메일은 로그인 ID로 사용되며 수정 불가능합니다
- 비밀번호 변경 시 현재 비밀번호 확인이 필요합니다

---

## 🧪 테스트 시나리오

### 기본 플로우
1. 회원가입 → 로그인 → userId 획득
2. 상품 목록 조회 → 상품 선택
3. 장바구니에 상품 추가
4. 장바구니 조회 → 수량 조정
5. 장바구니 기반 주문 생성
6. 주문 목록 조회 → 주문 상세 확인

### 예외 처리 테스트
- 재고 부족 상품 주문 시도
- 중복 이메일 회원가입 시도
- 잘못된 비밀번호로 로그인 시도
- CONFIRMED 상태 주문 취소 시도
- 빈 장바구니로 주문 시도

---

## 💡 프론트엔드 개발 팁

### 1. 인증 처리
```javascript
// 로그인 후 userId 저장
const loginResponse = await login(email, password);
localStorage.setItem('userId', loginResponse.userId);

// API 호출 시 헤더에 포함
const headers = {
  'Content-Type': 'application/json',
  'X-User-Id': localStorage.getItem('userId')
};
```

### 2. 페이징 처리
```javascript
// Spring Data의 Page 응답 구조
const { content, totalElements, totalPages, number, size } = response;
```

### 3. 에러 처리
```javascript
try {
  const response = await api.call();
} catch (error) {
  const { code, message, status } = error.response.data;
  // code로 에러 타입 구분
  // message를 사용자에게 표시
}
```

### 4. 장바구니 플로우
```javascript
// 1. 장바구니에 추가
await addToCart(productId, quantity);

// 2. 장바구니 조회 (실시간 가격 반영)
const cart = await getCart();

// 3. 장바구니에서 주문 생성
const order = await createOrderFromCart();
// 주문 성공 시 장바구니 자동 비워짐
```

---

## 📝 Validation 규칙

### 상품
- 상품명: 필수, 최대 100자, 중복 불가
- 가격: 필수, 0보다 커야 함
- 재고: 필수, 0 이상
- 카테고리: 필수 (ELECTRONICS/CLOTHING/FOOD/BOOK/HOME)

### 사용자
- 이메일: 필수, 이메일 형식, 최대 100자, 중복 불가
- 비밀번호: 필수, 최소 8자
- 이름: 필수, 최대 50자
- 전화번호: 선택, 최대 20자

### 주문
- 사용자 ID: 필수
- 주문 상품: 최소 1개 이상
- 수량: 1 이상

### 장바구니
- 상품 ID: 필수
- 수량: 1 이상

---

## 🔗 관련 문서

백엔드 프로젝트의 상세 문서는 `../ecommerce-demo/` 디렉토리를 참조하세요:
- `REQUIREMENTS.md`: 전체 요구사항 명세
- `DEVELOPMENT_RULES.md`: 개발 규칙
- `PLAN.md`: Sprint별 작업 계획
- `api-tests/`: HTTP Client 테스트 파일
