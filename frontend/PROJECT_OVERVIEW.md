# E-Commerce Demo Frontend - Project Overview

## 📋 프로젝트 개요

이 프로젝트는 E-Commerce Demo 애플리케이션의 프론트엔드입니다.
백엔드 API와 연동하여 이커머스 기능을 제공하는 웹 애플리케이션을 구현합니다.

## 🎯 목적

- 백엔드 API를 활용한 이커머스 웹 애플리케이션 구현
- 인프라 현대화 데모를 위한 프론트엔드 제공
- 사용자 친화적인 UI/UX 구현

## 🛠 기술 스택 (예정)

- **Framework**: React 18+
- **Build Tool**: Vite
- **State Management**: React Context API 또는 Redux
- **HTTP Client**: Axios
- **Styling**: CSS Modules 또는 Tailwind CSS
- **Routing**: React Router

## 📱 구현할 주요 기능

### 1. 사용자 인증
- 회원가입 페이지
- 로그인 페이지
- 로그아웃
- 내 정보 조회/수정
- 비밀번호 변경

### 2. 상품 관리
- 상품 목록 페이지 (페이징, 카테고리 필터)
- 상품 상세 페이지
- 상품 검색 (선택사항)

### 3. 장바구니
- 장바구니 페이지
- 상품 추가/삭제
- 수량 변경
- 장바구니에서 주문하기

### 4. 주문
- 주문 생성 (직접 또는 장바구니에서)
- 주문 목록 페이지
- 주문 상세 페이지
- 주문 취소

### 5. 공통
- 네비게이션 바
- 로딩 인디케이터
- 에러 처리 및 알림
- 반응형 디자인

## 🔗 백엔드 연동

### API Base URL
```javascript
const API_BASE_URL = 'http://localhost:8080';
```

### 인증 처리
```javascript
// 로그인 후 userId 저장
localStorage.setItem('userId', response.userId);

// API 호출 시 헤더에 포함
headers: {
  'X-User-Id': localStorage.getItem('userId')
}
```

### 주요 API 엔드포인트
- 상품: `/api/products`
- 사용자: `/api/users`
- 장바구니: `/api/carts`
- 주문: `/api/orders`

자세한 API 명세는 [BACKEND_API.md](./BACKEND_API.md)를 참조하세요.

## 📁 예상 프로젝트 구조

```
ecommerce-demo-frontend/
├── src/
│   ├── components/       # 재사용 가능한 컴포넌트
│   │   ├── common/      # 공통 컴포넌트 (Button, Input 등)
│   │   ├── product/     # 상품 관련 컴포넌트
│   │   ├── cart/        # 장바구니 관련 컴포넌트
│   │   └── order/       # 주문 관련 컴포넌트
│   ├── pages/           # 페이지 컴포넌트
│   │   ├── Home.jsx
│   │   ├── Login.jsx
│   │   ├── Signup.jsx
│   │   ├── ProductList.jsx
│   │   ├── ProductDetail.jsx
│   │   ├── Cart.jsx
│   │   ├── OrderList.jsx
│   │   └── OrderDetail.jsx
│   ├── services/        # API 호출 서비스
│   │   ├── api.js       # Axios 설정
│   │   ├── productService.js
│   │   ├── userService.js
│   │   ├── cartService.js
│   │   └── orderService.js
│   ├── context/         # Context API (상태 관리)
│   │   ├── AuthContext.jsx
│   │   └── CartContext.jsx
│   ├── utils/           # 유틸리티 함수
│   │   ├── formatters.js
│   │   └── validators.js
│   ├── App.jsx
│   └── main.jsx
├── public/
├── BACKEND_API.md       # 백엔드 API 문서
├── PROJECT_OVERVIEW.md  # 이 문서
└── package.json
```

## 🎨 UI/UX 가이드라인

### 페이지 구성
1. **홈페이지**: 상품 목록 (카테고리별 탭)
2. **상품 상세**: 상품 정보, 장바구니 담기 버튼
3. **장바구니**: 담긴 상품 목록, 수량 조절, 주문하기
4. **주문 목록**: 내 주문 내역, 상태별 필터
5. **주문 상세**: 주문 정보, 주문 상품 목록, 취소 버튼

### 사용자 플로우
```
회원가입 → 로그인 → 상품 목록 → 상품 상세 → 장바구니 담기 
→ 장바구니 확인 → 주문하기 → 주문 완료 → 주문 목록
```

## 🚀 개발 시작 가이드

### 1. 백엔드 실행
```bash
cd ../ecommerce-demo
./gradlew bootRun
```

### 2. 프론트엔드 개발 환경 설정
```bash
cd ecommerce-demo-frontend
npm install
npm run dev
```

### 3. API 테스트
백엔드의 `api-tests/` 디렉토리에 있는 HTTP Client 파일로 API를 먼저 테스트해보세요.

## 📝 개발 우선순위

### Phase 1: 기본 구조
1. React 프로젝트 초기 설정
2. 라우팅 설정
3. API 서비스 레이어 구현
4. 공통 컴포넌트 구현

### Phase 2: 인증 기능
1. 회원가입 페이지
2. 로그인 페이지
3. AuthContext 구현
4. 인증 상태 관리

### Phase 3: 상품 기능
1. 상품 목록 페이지
2. 상품 상세 페이지
3. 카테고리 필터
4. 페이징 처리

### Phase 4: 장바구니 기능
1. 장바구니 페이지
2. 장바구니 추가/삭제
3. 수량 변경
4. CartContext 구현

### Phase 5: 주문 기능
1. 주문 생성 (장바구니에서)
2. 주문 목록 페이지
3. 주문 상세 페이지
4. 주문 취소

## 🔍 참고사항

### 백엔드 특징
- 비밀번호는 평문으로 저장됩니다 (데모 목적)
- 인증은 간단한 헤더 기반입니다 (X-User-Id)
- 실제 운영 환경에서는 JWT 또는 세션 기반 인증으로 전환 필요

### 데이터 일관성
- 장바구니 조회 시 상품 정보는 실시간으로 조회됩니다
- 주문 내역의 상품 정보는 주문 시점의 정보입니다
- 상품 가격 변경 시 장바구니에는 반영되지만, 기존 주문에는 영향 없습니다

### CORS 설정
백엔드에서 CORS 설정이 필요할 수 있습니다. 개발 중 CORS 에러 발생 시 백엔드에 설정 추가가 필요합니다.
