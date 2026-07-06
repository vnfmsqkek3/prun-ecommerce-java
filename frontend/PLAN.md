# E-Commerce Demo Frontend - 작업 계획서

## 📋 문서 개요

이 문서는 E-Commerce Demo 프론트엔드 개발의 Phase별 작업 계획을 정의합니다.
각 Phase는 독립적으로 테스트 가능하며, 순차적으로 진행됩니다.

---

## 🎯 전체 목표

- React 기반 이커머스 웹 애플리케이션 구현
- 백엔드 API와 완벽한 연동
- 사용자 친화적인 UI/UX 제공
- 체계적인 테스트 및 검증

---

## 📅 Phase 개요

| Phase | 목표 | 예상 기간 |
|-------|------|----------|
| Phase 1 | 프로젝트 초기 설정 | 1일 |
| Phase 2 | 인증 기능 구현 | 1일 |
| Phase 3 | 상품 기능 구현 | 1일 |
| Phase 4 | 장바구니 기능 구현 | 1일 |
| Phase 5 | 주문 기능 구현 | 1일 |
| Phase 6 | 최종 테스트 및 마무리 | 1일 |

---

## Phase 1: 프로젝트 초기 설정

### 목표
React 프로젝트 생성 및 기본 구조 설정

### 작업 항목

#### 1.1 프로젝트 생성
- [x] Vite로 React 프로젝트 생성
- [x] 불필요한 파일 제거
- [x] Git 초기화 확인

#### 1.2 의존성 설치
- [x] React Router 설치
- [x] Axios 설치
- [x] 기타 필요한 라이브러리 설치

#### 1.3 프로젝트 구조 생성
- [x] `src/components/` 디렉토리 생성
  - [x] `common/`
  - [x] `product/`
  - [x] `cart/`
  - [x] `order/`
  - [x] `layout/`
- [x] `src/pages/` 디렉토리 생성
- [x] `src/services/` 디렉토리 생성
- [x] `src/context/` 디렉토리 생성
- [x] `src/utils/` 디렉토리 생성
- [x] `src/hooks/` 디렉토리 생성
- [x] `src/styles/` 디렉토리 생성

#### 1.4 API 서비스 레이어 구현
- [x] `services/api.js` 생성 (Axios 설정)
  - [x] baseURL 설정
  - [x] Request Interceptor (X-User-Id 헤더)
  - [x] Response Interceptor (에러 처리)
- [x] `services/productService.js` 생성
- [x] `services/userService.js` 생성
- [x] `services/cartService.js` 생성
- [x] `services/orderService.js` 생성

#### 1.5 공통 컴포넌트 구현
- [x] `components/common/Button.jsx`
- [x] `components/common/Input.jsx`
- [x] `components/common/Loading.jsx`
- [x] `components/common/Alert.jsx`
- [x] `components/common/Modal.jsx`

#### 1.6 레이아웃 구현
- [x] `components/layout/Layout.jsx`
- [x] `components/layout/Navigation.jsx`

#### 1.7 라우팅 설정
- [x] `App.jsx`에 React Router 설정
- [x] 기본 라우트 정의
- [x] ProtectedRoute 컴포넌트 구현

#### 1.8 유틸리티 함수
- [x] `utils/formatters.js` (가격, 날짜, 상태 포맷)
- [x] `utils/validators.js` (입력 검증)

#### 1.9 전역 스타일
- [x] `styles/global.css` 생성
- [x] CSS 변수 정의 (색상, 간격 등)

### 완료 기준
- [x] 프로젝트가 정상적으로 실행됨 (`npm run dev`)
- [x] 기본 레이아웃이 표시됨
- [x] 콘솔 에러 없음

### 테스트
- [x] 백엔드 서버 실행 확인
- [x] 프론트엔드 서버 실행 확인
- [x] 브라우저에서 기본 페이지 확인

---

## Phase 2: 인증 기능 구현

### 목표
회원가입, 로그인, 로그아웃 기능 구현

### 작업 항목

#### 2.1 AuthContext 구현
- [x] `context/AuthContext.jsx` 생성
- [x] 상태 정의 (user, userId, isAuthenticated)
- [x] login 함수 구현
- [x] logout 함수 구현
- [x] updateUser 함수 구현
- [x] localStorage 연동
- [x] useAuth Hook 구현

#### 2.2 회원가입 페이지
- [x] `pages/Signup.jsx` 생성
- [x] 회원가입 폼 UI 구현
- [x] 입력 검증 구현
- [x] API 연동 (userService.signup)
- [x] 에러 처리
- [x] 성공 시 로그인 페이지로 이동

#### 2.3 로그인 페이지
- [x] `pages/Login.jsx` 생성
- [x] 로그인 폼 UI 구현
- [x] API 연동 (userService.login)
- [x] AuthContext의 login 함수 호출
- [x] 에러 처리
- [x] 성공 시 홈으로 이동

#### 2.4 내 정보 페이지
- [x] `pages/Profile.jsx` 생성
- [x] 내 정보 조회 UI
- [x] 내 정보 수정 폼
- [x] 비밀번호 변경 폼
- [x] API 연동
- [x] 에러 처리

#### 2.5 Navigation 업데이트
- [x] 로그인 상태에 따른 메뉴 표시
- [x] 로그아웃 버튼 구현
- [x] 사용자 이름 표시

### 완료 기준
- [x] 회원가입 성공
- [x] 로그인 성공
- [x] 로그아웃 성공
- [x] 내 정보 조회/수정 성공
- [x] 비밀번호 변경 성공
- [x] 인증 상태가 Navigation에 반영됨

### 테스트
- [x] 회원가입 → 로그인 플로우 테스트
- [x] 중복 이메일 회원가입 에러 확인
- [x] 잘못된 비밀번호 로그인 에러 확인
- [x] 로그아웃 후 인증 필요 페이지 접근 차단 확인
- [x] 페이지 새로고침 시 인증 상태 유지 확인

---

## Phase 3: 상품 기능 구현

### 목표
상품 목록, 상품 상세 페이지 구현

### 작업 항목

#### 3.1 상품 컴포넌트
- [x] `components/product/ProductCard.jsx` 생성
- [x] `components/product/ProductList.jsx` 생성

#### 3.2 홈 페이지
- [x] `pages/Home.jsx` 생성
- [x] 카테고리 탭 UI 구현
- [x] ProductList 컴포넌트 사용
- [x] 페이지네이션 구현
- [x] API 연동 (productService.getProducts)
- [x] 로딩 상태 처리
- [x] 에러 처리

#### 3.3 상품 목록 페이지
- [x] `pages/ProductList.jsx` 생성 (또는 Home 재사용)
- [x] 카테고리 필터 구현
- [x] 페이징 처리
- [x] 상품 카드 클릭 시 상세 페이지 이동

#### 3.4 상품 상세 페이지
- [x] `pages/ProductDetail.jsx` 생성
- [x] 상품 정보 표시 UI
- [x] 수량 선택 UI
- [x] "장바구니 담기" 버튼
- [x] "바로 주문하기" 버튼
- [x] API 연동 (productService.getProductById)
- [x] 장바구니 추가 기능 (cartService.addToCart)
- [x] 에러 처리

### 완료 기준
- [x] 상품 목록이 정상적으로 표시됨
- [x] 카테고리 필터가 작동함
- [x] 페이징이 작동함
- [x] 상품 상세 페이지가 표시됨
- [x] 장바구니 담기가 작동함

### 테스트
- [x] 상품 목록 조회 테스트
- [x] 카테고리별 필터링 테스트
- [x] 페이지 이동 테스트
- [x] 상품 상세 조회 테스트
- [x] 장바구니 담기 테스트
- [x] 재고 부족 상품 에러 처리 확인

---

## Phase 4: 장바구니 기능 구현

### 목표
장바구니 조회, 수량 변경, 삭제, 주문하기 기능 구현

### 작업 항목

#### 4.1 장바구니 컴포넌트
- [x] `components/cart/CartItem.jsx` 생성

#### 4.2 장바구니 페이지
- [x] `pages/Cart.jsx` 생성
- [x] 장바구니 목록 UI
- [x] 수량 조절 버튼 (+/-)
- [x] 삭제 버튼
- [x] 전체 삭제 버튼
- [x] 총 금액 계산 및 표시
- [x] "주문하기" 버튼
- [x] API 연동
  - [x] cartService.getCart
  - [x] cartService.updateCartItem
  - [x] cartService.removeCartItem
  - [x] cartService.clearCart
- [x] 로딩 상태 처리
- [x] 에러 처리

#### 4.3 장바구니 상태 관리 (선택사항)
- [x] CartContext 생성 (필요 시)
- [x] 장바구니 개수 표시 (Navigation)

### 완료 기준
- [x] 장바구니 조회 성공
- [x] 수량 변경 성공
- [x] 상품 삭제 성공
- [x] 전체 삭제 성공
- [x] 총 금액이 정확히 계산됨
- [x] 빈 장바구니 처리

### 테스트
- [x] 장바구니 조회 테스트
- [x] 수량 증가/감소 테스트
- [x] 상품 삭제 테스트
- [x] 전체 삭제 테스트
- [x] 빈 장바구니 메시지 확인
- [x] 실시간 가격 반영 확인

---

## Phase 5: 주문 기능 구현

### 목표
주문 생성, 주문 목록, 주문 상세, 주문 취소 기능 구현

### 작업 항목

#### 5.1 주문 컴포넌트
- [x] `components/order/OrderCard.jsx` 생성
- [x] `components/order/OrderItem.jsx` 생성

#### 5.2 주문 생성
- [x] 장바구니에서 주문하기 기능 구현
- [x] API 연동 (orderService.createOrderFromCart)
- [x] 성공 시 주문 목록 페이지로 이동
- [x] 에러 처리

#### 5.3 주문 목록 페이지
- [x] `pages/OrderList.jsx` 생성
- [x] 주문 카드 목록 UI
- [x] 상태별 필터 (전체, 대기중, 확인됨, 취소됨)
- [x] 페이지네이션
- [x] API 연동 (orderService.getOrders)
- [x] 로딩 상태 처리
- [x] 에러 처리

#### 5.4 주문 상세 페이지
- [x] `pages/OrderDetail.jsx` 생성
- [x] 주문 정보 표시 UI
- [x] 주문 상품 목록 표시
- [x] "주문 취소" 버튼 (PENDING 상태만)
- [x] API 연동
  - [x] orderService.getOrderById
  - [x] orderService.cancelOrder
- [x] 에러 처리

### 완료 기준
- [x] 장바구니에서 주문 생성 성공
- [x] 주문 목록 조회 성공
- [x] 주문 상세 조회 성공
- [x] 주문 취소 성공 (PENDING 상태)
- [x] 주문 취소 불가 처리 (CONFIRMED 상태)

### 테스트
- [x] 장바구니에서 주문 생성 테스트
- [x] 주문 성공 시 장바구니 비워짐 확인
- [x] 주문 목록 조회 테스트
- [x] 상태별 필터링 테스트
- [x] 주문 상세 조회 테스트
- [x] PENDING 주문 취소 테스트
- [x] CONFIRMED 주문 취소 불가 확인
- [x] 재고 부족 주문 에러 처리 확인

---

## Phase 6: 최종 테스트 및 마무리

### 목표
전체 기능 통합 테스트 및 문서 정리

### 작업 항목

#### 6.1 통합 테스트
- [x] 전체 사용자 플로우 테스트
  - [x] 회원가입 → 로그인
  - [x] 상품 목록 → 상품 상세
  - [x] 장바구니 담기 → 장바구니 확인
  - [x] 수량 조절 → 주문하기
  - [x] 주문 목록 → 주문 상세
  - [x] 주문 취소
  - [x] 로그아웃

#### 6.2 에러 케이스 테스트
- [x] 중복 이메일 회원가입
- [x] 잘못된 비밀번호 로그인
- [x] 재고 부족 상품 주문
- [x] 빈 장바구니 주문
- [x] CONFIRMED 주문 취소 시도
- [x] 네트워크 에러 처리

#### 6.3 반응형 디자인 확인
- [x] Desktop (1200px 이상)
- [x] Tablet (768px ~ 1199px)
- [x] Mobile (767px 이하)

#### 6.4 성능 최적화
- [x] 불필요한 리렌더링 확인
- [x] React.memo 적용 (필요 시)
- [x] useCallback 적용 (필요 시)
- [x] 코드 스플리팅 확인

#### 6.5 코드 품질 확인
- [x] ESLint 경고 해결
- [x] 콘솔 에러/경고 제거
- [x] 주석 정리
- [x] 불필요한 코드 제거

#### 6.6 문서 작성
- [x] README.md 작성
  - [x] 프로젝트 소개
  - [x] 설치 방법
  - [x] 실행 방법
  - [x] 기능 목록
  - [x] 기술 스택
  - [x] 프로젝트 구조
- [x] PLAN.md 최종 업데이트
- [x] Git 커밋 히스토리 정리

### 완료 기준
- [x] 모든 기능이 정상 작동함
- [x] 모든 에러 케이스가 적절히 처리됨
- [x] 반응형 디자인이 모든 디바이스에서 작동함
- [x] 콘솔 에러/경고 없음
- [x] 문서가 완성됨

### 테스트
- [x] 전체 플로우 Playwright 테스트
- [x] 다양한 브라우저에서 테스트 (Chrome, Firefox, Safari)
- [x] 다양한 디바이스에서 테스트

---

## 📊 진행 상황 추적

| Phase | 상태 | 시작일 | 완료일 | 비고 |
|-------|------|--------|--------|------|
| Phase 1 | ✅ 완료 | 2025-12-10 | 2025-12-10 | 프로젝트 초기 설정 |
| Phase 2 | ✅ 완료 | 2025-12-10 | 2025-12-10 | 인증 기능 (CORS 설정 포함) |
| Phase 3 | ✅ 완료 | 2025-12-10 | 2025-12-10 | 상품 기능 |
| Phase 4 | ✅ 완료 | 2025-12-10 | 2025-12-10 | 장바구니 기능 |
| Phase 5 | ✅ 완료 | 2025-12-10 | 2025-12-10 | 주문 기능 |
| Phase 6 | ✅ 완료 | 2025-12-10 | 2025-12-10 | 최종 테스트 및 마무리 |

**상태 범례:**
- ⬜ 대기
- 🟦 진행중
- ✅ 완료
- ❌ 보류

---

## 🎯 다음 단계

**현재 Phase**: Phase 2 - 인증 기능 구현

**다음 작업**: 
1. AuthContext 구현 (완료)
2. 회원가입 페이지 구현
3. 로그인 페이지 구현

---

## 📝 변경 이력

| 날짜 | 변경 내용 | 작성자 |
|------|----------|--------|
| 2025-12-10 | 초기 작성 | - |

---

## 💡 참고사항

### 작업 진행 방법
1. 각 Phase의 작업 항목을 순서대로 진행
2. 작업 완료 시 체크박스 체크
3. Phase 완료 시 테스트 수행
4. 테스트 통과 시 다음 Phase로 진행
5. 진행 상황 테이블 업데이트

### Git 커밋 규칙
- 각 작업 항목 완료 시 커밋
- 커밋 메시지 형식: `<type>: <subject>`
- Phase 완료 시 태그 생성 (예: `v1.0-phase1`)

### 문제 발생 시
- 문제 내용을 PLAN.md에 기록
- 해결 방법 모색
- 필요 시 Phase 순서 조정
