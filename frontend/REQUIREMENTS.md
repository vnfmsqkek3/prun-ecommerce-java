# E-Commerce Demo Frontend - 요구사항 명세서

## 📋 문서 개요

이 문서는 E-Commerce Demo 프론트엔드 애플리케이션의 상세 요구사항을 정의합니다.
백엔드 API 명세(BACKEND_API.md)와 프로젝트 개요(PROJECT_OVERVIEW.md)를 기반으로 작성되었습니다.

---

## 🎯 프로젝트 목표

- 백엔드 API와 완벽히 연동되는 이커머스 웹 애플리케이션 구현
- 사용자 친화적인 UI/UX 제공
- 반응형 디자인으로 다양한 디바이스 지원
- 명확한 에러 처리 및 사용자 피드백

---

## 🛠 기술 스택

### Core
- **Framework**: React 18+
- **Build Tool**: Vite
- **Language**: JavaScript (ES6+)

### Libraries
- **Routing**: React Router v6
- **HTTP Client**: Axios
- **State Management**: React Context API
- **Styling**: CSS Modules

### Development
- **Testing**: Playwright (브라우저 자동화)
- **Code Quality**: ESLint

---

## 📱 페이지 구조

### 1. 공통 레이아웃
- **Navigation Bar**
  - 로고 (홈으로 이동)
  - 메뉴: 홈, 장바구니, 주문내역
  - 사용자 정보 (로그인 시)
  - 로그인/로그아웃 버튼

### 2. 페이지 목록
1. **홈 페이지** (`/`)
2. **회원가입** (`/signup`)
3. **로그인** (`/login`)
4. **상품 목록** (`/products`)
5. **상품 상세** (`/products/:id`)
6. **장바구니** (`/cart`)
7. **주문 목록** (`/orders`)
8. **주문 상세** (`/orders/:id`)
9. **내 정보** (`/profile`)

---

## 📄 페이지별 상세 요구사항

### 1. 홈 페이지 (`/`)

#### 기능
- 상품 목록 표시 (ProductList 컴포넌트 재사용)
- 카테고리별 탭 필터
- 페이징 처리

#### UI 요소
- 카테고리 탭: 전체, 전자제품, 의류, 식품, 도서, 생활용품
- 상품 카드 그리드 (4열)
- 페이지네이션

---

### 2. 회원가입 페이지 (`/signup`)

#### 기능
- 회원가입 폼 제출
- 입력 검증
- 성공 시 로그인 페이지로 이동

#### 입력 필드
- 이메일 (필수, 이메일 형식)
- 비밀번호 (필수, 최소 8자)
- 비밀번호 확인 (필수, 일치 확인)
- 이름 (필수, 최대 50자)
- 전화번호 (선택, 최대 20자)

#### 검증 규칙
- 이메일: 이메일 형식 검증
- 비밀번호: 최소 8자 이상
- 비밀번호 확인: 비밀번호와 일치
- 이름: 필수 입력
- 전화번호: 숫자와 하이픈만 허용

#### 에러 처리
- `DUPLICATE_EMAIL`: "이미 사용 중인 이메일입니다"
- `INVALID_INPUT`: 백엔드 메시지 표시
- 네트워크 에러: "서버에 연결할 수 없습니다"

---

### 3. 로그인 페이지 (`/login`)

#### 기능
- 로그인 폼 제출
- userId 저장 (localStorage)
- 성공 시 홈으로 이동

#### 입력 필드
- 이메일 (필수)
- 비밀번호 (필수)

#### 에러 처리
- `INVALID_CREDENTIALS`: "이메일 또는 비밀번호가 일치하지 않습니다"
- 네트워크 에러: "서버에 연결할 수 없습니다"

#### 추가 기능
- "회원가입" 링크

---

### 4. 상품 목록 페이지 (`/products`)

#### 기능
- 상품 목록 조회 (페이징)
- 카테고리 필터
- 상품 카드 클릭 시 상세 페이지 이동

#### UI 요소
- 카테고리 필터 (드롭다운 또는 탭)
- 상품 카드 그리드
  - 상품 이미지
  - 상품명
  - 가격
  - 재고 상태
- 페이지네이션

#### API 연동
- `GET /api/products?page={page}&size=20&category={category}`
- 페이지 크기: 20개

---

### 5. 상품 상세 페이지 (`/products/:id`)

#### 기능
- 상품 상세 정보 표시
- 수량 선택
- 장바구니 담기
- 바로 주문하기

#### UI 요소
- 상품 이미지
- 상품명
- 가격
- 설명
- 재고 수량
- 카테고리
- 수량 선택 (1 ~ 재고 수량)
- "장바구니 담기" 버튼
- "바로 주문하기" 버튼

#### 에러 처리
- `PRODUCT_NOT_FOUND`: "상품을 찾을 수 없습니다"
- 재고 부족: "재고가 부족합니다"

---

### 6. 장바구니 페이지 (`/cart`)

#### 기능
- 장바구니 조회
- 수량 변경
- 상품 삭제
- 전체 삭제
- 주문하기

#### UI 요소
- 장바구니 상품 목록
  - 상품 이미지
  - 상품명
  - 가격 (실시간)
  - 수량 조절 (+/- 버튼)
  - 삭제 버튼
- 총 금액 표시
- "전체 삭제" 버튼
- "주문하기" 버튼

#### 에러 처리
- `EMPTY_CART`: "장바구니가 비어있습니다"
- `CART_ITEM_NOT_FOUND`: "상품을 찾을 수 없습니다"
- `INSUFFICIENT_STOCK`: 백엔드 메시지 표시

#### 인증 필요
- 로그인하지 않은 경우 로그인 페이지로 리다이렉트

---

### 7. 주문 목록 페이지 (`/orders`)

#### 기능
- 주문 목록 조회 (페이징)
- 주문 상태별 필터
- 주문 카드 클릭 시 상세 페이지 이동

#### UI 요소
- 상태 필터 (전체, 대기중, 확인됨, 취소됨)
- 주문 카드 목록
  - 주문 번호
  - 주문 날짜
  - 총 금액
  - 주문 상태
  - 상품 개수
- 페이지네이션

#### API 연동
- `GET /api/orders?userId={userId}&page={page}&size=20&status={status}`

#### 인증 필요
- 로그인하지 않은 경우 로그인 페이지로 리다이렉트

---

### 8. 주문 상세 페이지 (`/orders/:id`)

#### 기능
- 주문 상세 정보 표시
- 주문 취소 (PENDING 상태만)

#### UI 요소
- 주문 정보
  - 주문 번호
  - 주문 날짜
  - 주문 상태
  - 총 금액
- 주문 상품 목록
  - 상품명
  - 가격 (주문 시점)
  - 수량
  - 소계
- "주문 취소" 버튼 (PENDING 상태만 표시)

#### 에러 처리
- `ORDER_NOT_FOUND`: "주문을 찾을 수 없습니다"
- `CANNOT_CANCEL_ORDER`: "취소할 수 없는 주문입니다"

#### 인증 필요
- 로그인하지 않은 경우 로그인 페이지로 리다이렉트

---

### 9. 내 정보 페이지 (`/profile`)

#### 기능
- 내 정보 조회
- 내 정보 수정
- 비밀번호 변경

#### UI 요소
- **내 정보 섹션**
  - 이메일 (수정 불가)
  - 이름 (수정 가능)
  - 전화번호 (수정 가능)
  - "저장" 버튼

- **비밀번호 변경 섹션**
  - 현재 비밀번호
  - 새 비밀번호
  - 새 비밀번호 확인
  - "변경" 버튼

#### 에러 처리
- `USER_NOT_FOUND`: "사용자를 찾을 수 없습니다"
- `INVALID_CREDENTIALS`: "현재 비밀번호가 일치하지 않습니다"

#### 인증 필요
- 로그인하지 않은 경우 로그인 페이지로 리다이렉트

---

## 🔧 컴포넌트 설계

### 공통 컴포넌트 (`components/common/`)

#### Button
```jsx
<Button 
  variant="primary|secondary|danger"
  size="small|medium|large"
  onClick={handleClick}
  disabled={false}
>
  버튼 텍스트
</Button>
```

#### Input
```jsx
<Input 
  type="text|email|password|number"
  value={value}
  onChange={handleChange}
  placeholder="입력하세요"
  error="에러 메시지"
  required={true}
/>
```

#### Loading
```jsx
<Loading size="small|medium|large" />
```

#### Modal
```jsx
<Modal 
  isOpen={isOpen}
  onClose={handleClose}
  title="제목"
>
  내용
</Modal>
```

#### Alert
```jsx
<Alert 
  type="success|error|warning|info"
  message="메시지"
  onClose={handleClose}
/>
```

---

### 상품 컴포넌트 (`components/product/`)

#### ProductCard
```jsx
<ProductCard 
  product={product}
  onClick={handleClick}
/>
```

**표시 정보:**
- 상품 이미지
- 상품명
- 가격
- 재고 상태

#### ProductList
```jsx
<ProductList 
  products={products}
  loading={loading}
  onProductClick={handleProductClick}
/>
```

---

### 장바구니 컴포넌트 (`components/cart/`)

#### CartItem
```jsx
<CartItem 
  item={item}
  onQuantityChange={handleQuantityChange}
  onRemove={handleRemove}
/>
```

**표시 정보:**
- 상품 이미지
- 상품명
- 가격
- 수량 조절 버튼
- 삭제 버튼

---

### 주문 컴포넌트 (`components/order/`)

#### OrderCard
```jsx
<OrderCard 
  order={order}
  onClick={handleClick}
/>
```

**표시 정보:**
- 주문 번호
- 주문 날짜
- 총 금액
- 주문 상태
- 상품 개수

#### OrderItem
```jsx
<OrderItem item={item} />
```

**표시 정보:**
- 상품명
- 가격
- 수량
- 소계

---

### 레이아웃 컴포넌트 (`components/layout/`)

#### Layout
```jsx
<Layout>
  <Navigation />
  <main>{children}</main>
</Layout>
```

#### Navigation
```jsx
<Navigation />
```

**메뉴 항목:**
- 홈
- 장바구니
- 주문내역
- 내 정보 (로그인 시)
- 로그인/로그아웃

---

## 🔄 상태 관리 설계

### AuthContext

**상태:**
- `user`: 사용자 정보 (User 객체)
- `userId`: 사용자 ID (number)
- `isAuthenticated`: 로그인 여부 (boolean)

**함수:**
- `login(email, password)`: 로그인
- `logout()`: 로그아웃
- `updateUser(userData)`: 사용자 정보 업데이트

**초기화:**
- localStorage에서 userId 읽어서 복원
- userId가 있으면 `/api/users/me` 호출하여 사용자 정보 조회

---

## 🌐 라우팅 구조

### Public Routes (인증 불필요)
- `/` - 홈
- `/signup` - 회원가입
- `/login` - 로그인
- `/products` - 상품 목록
- `/products/:id` - 상품 상세

### Protected Routes (인증 필요)
- `/cart` - 장바구니
- `/orders` - 주문 목록
- `/orders/:id` - 주문 상세
- `/profile` - 내 정보

**인증 체크:**
- Protected Route는 `ProtectedRoute` 컴포넌트로 감싸기
- 미인증 시 로그인 페이지로 리다이렉트
- 로그인 후 원래 페이지로 돌아가기 (location.state 활용)

---

## 📡 API 서비스 설계

### api.js (Axios 설정)
```javascript
const api = axios.create({
  baseURL: 'http://localhost:8080',
  headers: {
    'Content-Type': 'application/json'
  }
});

// Request Interceptor: userId 헤더 추가
api.interceptors.request.use(config => {
  const userId = localStorage.getItem('userId');
  if (userId) {
    config.headers['X-User-Id'] = userId;
  }
  return config;
});

// Response Interceptor: 에러 처리
api.interceptors.response.use(
  response => response,
  error => {
    // 401 에러 시 로그아웃 처리
    if (error.response?.status === 401) {
      localStorage.removeItem('userId');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);
```

### productService.js
- `getProducts(page, size, category)`: 상품 목록 조회
- `getProductById(id)`: 상품 상세 조회
- `createProduct(productData)`: 상품 등록 (관리자용, 미구현)
- `updateProduct(id, productData)`: 상품 수정 (관리자용, 미구현)
- `deleteProduct(id)`: 상품 삭제 (관리자용, 미구현)

### userService.js
- `signup(userData)`: 회원가입
- `login(email, password)`: 로그인
- `getMe()`: 내 정보 조회
- `updateMe(userData)`: 내 정보 수정
- `changePassword(currentPassword, newPassword)`: 비밀번호 변경

### cartService.js
- `getCart()`: 장바구니 조회
- `addToCart(productId, quantity)`: 장바구니에 추가
- `updateCartItem(cartItemId, quantity)`: 수량 변경
- `removeCartItem(cartItemId)`: 상품 삭제
- `clearCart()`: 전체 삭제

### orderService.js
- `createOrder(orderData)`: 주문 생성 (직접)
- `createOrderFromCart()`: 장바구니에서 주문 생성
- `getOrders(page, size, status)`: 주문 목록 조회
- `getOrderById(id)`: 주문 상세 조회
- `cancelOrder(id)`: 주문 취소

---

## 🎨 UI/UX 요구사항

### 반응형 디자인
- **Desktop**: 1200px 이상
- **Tablet**: 768px ~ 1199px
- **Mobile**: 767px 이하

### 색상 팔레트
- **Primary**: #007bff (파란색)
- **Secondary**: #6c757d (회색)
- **Success**: #28a745 (초록색)
- **Danger**: #dc3545 (빨간색)
- **Warning**: #ffc107 (노란색)
- **Info**: #17a2b8 (청록색)

### 타이포그래피
- **Font Family**: 'Noto Sans KR', sans-serif
- **Heading**: 24px ~ 32px, Bold
- **Body**: 14px ~ 16px, Regular
- **Small**: 12px, Regular

### 간격
- **Small**: 8px
- **Medium**: 16px
- **Large**: 24px
- **XLarge**: 32px

---

## ⚠️ 에러 처리 요구사항

### 에러 메시지 표시
- Alert 컴포넌트 사용
- 에러 타입에 따라 색상 구분
- 자동으로 사라지거나 닫기 버튼 제공

### 에러 코드별 메시지
| 에러 코드 | 사용자 메시지 |
|----------|-------------|
| `PRODUCT_NOT_FOUND` | 상품을 찾을 수 없습니다 |
| `DUPLICATE_PRODUCT_NAME` | 중복된 상품명입니다 |
| `INSUFFICIENT_STOCK` | 재고가 부족합니다 (백엔드 메시지 사용) |
| `USER_NOT_FOUND` | 사용자를 찾을 수 없습니다 |
| `DUPLICATE_EMAIL` | 이미 사용 중인 이메일입니다 |
| `INVALID_CREDENTIALS` | 이메일 또는 비밀번호가 일치하지 않습니다 |
| `ORDER_NOT_FOUND` | 주문을 찾을 수 없습니다 |
| `INVALID_ORDER_STATUS` | 유효하지 않은 주문 상태입니다 |
| `CANNOT_CANCEL_ORDER` | 취소할 수 없는 주문입니다 |
| `EMPTY_ORDER_ITEMS` | 주문 상품이 없습니다 |
| `CART_ITEM_NOT_FOUND` | 장바구니 상품을 찾을 수 없습니다 |
| `EMPTY_CART` | 장바구니가 비어있습니다 |
| `INVALID_INPUT` | 입력 정보를 확인해주세요 |
| `INTERNAL_SERVER_ERROR` | 서버 오류가 발생했습니다 |
| 네트워크 에러 | 서버에 연결할 수 없습니다 |

---

## 🔒 보안 요구사항

### 인증 정보 관리
- userId는 localStorage에 저장
- 로그아웃 시 localStorage 클리어
- 페이지 새로고침 시 인증 상태 복원

### XSS 방지
- React의 기본 이스케이프 활용
- `dangerouslySetInnerHTML` 사용 금지

### 민감 정보
- 비밀번호는 평문으로 표시하지 않음 (type="password")
- API 키 등은 환경 변수로 관리

---

## ✅ 검증 규칙

### 회원가입
- 이메일: 이메일 형식, 최대 100자
- 비밀번호: 최소 8자
- 이름: 필수, 최대 50자
- 전화번호: 선택, 최대 20자

### 상품
- 수량: 1 이상, 재고 수량 이하

### 장바구니
- 수량: 1 이상

### 주문
- 최소 1개 이상의 상품

---

## 📊 데이터 포맷

### 가격
- 표시: `1,500,000원` (천 단위 콤마)
- 저장: `1500000` (number)

### 날짜
- 표시: `2025년 12월 10일` (한글 형식)
- 저장: `2025-12-10T10:00:00` (ISO 8601)

### 주문 상태
- `PENDING`: 대기중
- `CONFIRMED`: 확인됨
- `CANCELLED`: 취소됨

### 카테고리
- `ELECTRONICS`: 전자제품
- `CLOTHING`: 의류
- `FOOD`: 식품
- `BOOK`: 도서
- `HOME`: 생활용품

---

## 🧪 테스트 시나리오

### 기본 플로우
1. 회원가입 → 로그인
2. 상품 목록 조회 → 상품 상세
3. 장바구니 담기 → 장바구니 확인
4. 수량 조절 → 주문하기
5. 주문 목록 → 주문 상세

### 에러 케이스
1. 중복 이메일 회원가입
2. 잘못된 비밀번호 로그인
3. 재고 부족 상품 주문
4. 빈 장바구니 주문
5. CONFIRMED 주문 취소 시도

### 인증 테스트
1. 미인증 상태에서 장바구니 접근
2. 미인증 상태에서 주문 목록 접근
3. 로그인 후 원래 페이지로 돌아가기

---

## 📝 완료 기준

### 기능 완료
- [ ] 모든 페이지 구현 완료
- [ ] 모든 API 연동 완료
- [ ] 에러 처리 구현 완료
- [ ] 로딩 상태 구현 완료

### 품질 완료
- [ ] 브라우저 테스트 통과
- [ ] 반응형 디자인 확인
- [ ] 콘솔 에러/경고 없음
- [ ] 코드 리뷰 완료

### 문서 완료
- [ ] PLAN.md 모든 체크박스 완료
- [ ] Git 커밋 히스토리 정리
- [ ] README.md 작성

---

## 🔗 참고 문서

- [BACKEND_API.md](./BACKEND_API.md) - 백엔드 API 명세
- [PROJECT_OVERVIEW.md](./PROJECT_OVERVIEW.md) - 프로젝트 개요
- [DEVELOPMENT_RULES.md](./DEVELOPMENT_RULES.md) - 개발 규칙
- [PLAN.md](./PLAN.md) - 작업 계획 (작성 예정)
