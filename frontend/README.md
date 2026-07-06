# E-Commerce Demo Frontend

React 기반 이커머스 웹 애플리케이션

## 🎯 프로젝트 소개

이 프로젝트는 Spring Boot 백엔드 API와 연동하여 이커머스 기능을 제공하는 웹 애플리케이션입니다.

## ✨ 주요 기능

### 인증
- 회원가입 (이메일, 비밀번호, 이름, 전화번호)
- 로그인/로그아웃
- 내 정보 조회 및 수정
- 비밀번호 변경

### 상품
- 상품 목록 조회 (페이징)
- 카테고리별 필터링 (전자제품, 의류, 식품, 도서, 생활용품)
- 상품 상세 조회
- 장바구니 담기

### 장바구니
- 장바구니 조회
- 수량 변경 (+/- 버튼)
- 상품 삭제
- 전체 삭제
- 총 금액 계산
- 주문하기

### 주문
- 장바구니에서 주문 생성
- 주문 목록 조회 (페이징)
- 주문 상태별 필터링 (전체, 대기중, 확인됨, 취소됨)
- 주문 상세 조회
- 주문 취소 (PENDING 상태만)

## 🛠 기술 스택

- **Framework**: React 18
- **Build Tool**: Vite
- **Routing**: React Router v6
- **HTTP Client**: Axios
- **State Management**: React Context API
- **Styling**: CSS Modules

## 📦 설치 방법

```bash
npm install
```

## 🚀 실행 방법

### 1. 백엔드 서버 실행
```bash
cd ../ecommerce-demo
./gradlew bootRun
```

백엔드 서버: http://localhost:8080

### 2. 프론트엔드 개발 서버 실행
```bash
npm run dev
```

프론트엔드 서버: http://localhost:5173

## 📁 프로젝트 구조

```
src/
├── components/
│   ├── common/          # 공통 컴포넌트
│   │   ├── Button.jsx
│   │   ├── Input.jsx
│   │   ├── Loading.jsx
│   │   ├── Alert.jsx
│   │   ├── Modal.jsx
│   │   └── ProtectedRoute.jsx
│   ├── product/         # 상품 컴포넌트
│   │   ├── ProductCard.jsx
│   │   └── ProductList.jsx
│   ├── cart/            # 장바구니 컴포넌트
│   │   └── CartItem.jsx
│   ├── order/           # 주문 컴포넌트
│   │   ├── OrderCard.jsx
│   │   └── OrderItem.jsx
│   └── layout/          # 레이아웃
│       ├── Layout.jsx
│       └── Navigation.jsx
├── pages/               # 페이지
│   ├── Home.jsx
│   ├── Signup.jsx
│   ├── Login.jsx
│   ├── Profile.jsx
│   ├── ProductDetail.jsx
│   ├── Cart.jsx
│   ├── OrderList.jsx
│   └── OrderDetail.jsx
├── services/            # API 서비스
│   ├── api.js
│   ├── productService.js
│   ├── userService.js
│   ├── cartService.js
│   └── orderService.js
├── context/             # Context API
│   └── AuthContext.jsx
├── utils/               # 유틸리티
│   ├── formatters.js
│   └── validators.js
└── styles/              # 스타일
    └── global.css
```

## 🔐 인증 방식

- 로그인 시 `userId`를 localStorage에 저장
- API 요청 시 `X-User-Id` 헤더에 포함
- 인증이 필요한 페이지는 ProtectedRoute로 보호

## 🌐 API 연동

- **Base URL**: http://localhost:8080
- **인증 헤더**: X-User-Id
- **에러 처리**: Axios Interceptor

자세한 API 명세는 [BACKEND_API.md](./BACKEND_API.md)를 참조하세요.

## 📱 페이지 구조

- `/` - 홈 (상품 목록)
- `/signup` - 회원가입
- `/login` - 로그인
- `/products/:id` - 상품 상세
- `/cart` - 장바구니 (인증 필요)
- `/orders` - 주문 목록 (인증 필요)
- `/orders/:id` - 주문 상세 (인증 필요)
- `/profile` - 내 정보 (인증 필요)

## 🧪 테스트 시나리오

### 기본 플로우
1. 회원가입 → 로그인
2. 상품 목록 조회 → 상품 상세
3. 장바구니 담기 → 장바구니 확인
4. 수량 조절 → 주문하기
5. 주문 목록 → 주문 상세 → 주문 취소

### 에러 케이스
- 중복 이메일 회원가입
- 잘못된 비밀번호 로그인
- 미인증 상태에서 보호된 페이지 접근

## 📝 개발 문서

- [REQUIREMENTS.md](./REQUIREMENTS.md) - 요구사항 명세서
- [PLAN.md](./PLAN.md) - 작업 계획서
- [DEVELOPMENT_RULES.md](./DEVELOPMENT_RULES.md) - 개발 규칙
- [BACKEND_API.md](./BACKEND_API.md) - 백엔드 API 명세

## ✅ 완료 상태

- ✅ Phase 1: 프로젝트 초기 설정
- ✅ Phase 2: 인증 기능
- ✅ Phase 3: 상품 기능
- ✅ Phase 4: 장바구니 기능
- ✅ Phase 5: 주문 기능
- ✅ Phase 6: 최종 테스트 및 마무리

## 🎨 주요 특징

- 반응형 디자인 (Desktop, Tablet, Mobile)
- 직관적인 UI/UX
- 실시간 에러 처리 및 사용자 피드백
- 페이지네이션 지원
- 카테고리 및 상태 필터링

## 📄 라이선스

MIT
