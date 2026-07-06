# 프론트엔드 개발 규칙 (Frontend Development Rules)

## 기능 구현 순서

### 1. 구현 순서
기능 구현 시 다음 순서를 따른다:
1. **API Service** 함수 작성
2. **컴포넌트** 구현 (UI)
3. **상태 관리** 연결
4. **브라우저 테스트** 수행

### 2. 테스트 및 검증
컴포넌트 구현 완료 후 다음 절차를 수행한다:
1. **백엔드 서버 실행** (`cd ../ecommerce-demo && ./gradlew bootRun`)
2. **프론트엔드 서버 실행** (`npm run dev`)
3. **Playwright로 브라우저 자동화 테스트**
   - 브라우저 열기
   - 기능 동작 테스트 (클릭, 입력, 확인)
   - 결과 확인 (성공/실패, 에러 메시지)
4. **콘솔 에러 확인** (에러/경고 없어야 함)
5. **네트워크 탭 확인** (API 호출 성공 확인)

### 3. 테스트 시나리오
각 기능별로 다음을 확인한다:
- **정상 케이스**: 기능이 정상적으로 작동하는지
- **에러 케이스**: 에러가 적절히 처리되는지
- **UI 피드백**: 로딩, 성공, 에러 메시지가 표시되는지
- **데이터 일관성**: 백엔드 데이터와 일치하는지

## 코드 작성 규칙

### 1. 프로젝트 구조
**Feature 기반 + Layer 분리**

```
src/
├── components/
│   ├── common/          # 공통 컴포넌트
│   │   ├── Button.jsx
│   │   ├── Input.jsx
│   │   └── Modal.jsx
│   ├── product/         # 상품 관련
│   │   ├── ProductCard.jsx
│   │   └── ProductList.jsx
│   ├── cart/            # 장바구니 관련
│   │   └── CartItem.jsx
│   ├── order/           # 주문 관련
│   │   └── OrderCard.jsx
│   └── layout/          # 레이아웃
│       ├── Layout.jsx
│       └── Navigation.jsx
├── pages/               # 페이지 컴포넌트
│   ├── Home.jsx
│   ├── Login.jsx
│   └── Cart.jsx
├── services/            # API 호출
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
├── hooks/               # Custom Hooks
│   └── useAuth.js
└── styles/              # 스타일
    └── global.css
```

### 2. 네이밍 컨벤션

#### 파일명
- **컴포넌트**: `PascalCase.jsx` (예: `ProductCard.jsx`, `CartItem.jsx`)
- **Service**: `camelCase.js` (예: `productService.js`, `userService.js`)
- **Utils**: `camelCase.js` (예: `formatters.js`, `validators.js`)
- **Hooks**: `use{Name}.js` (예: `useAuth.js`, `useCart.js`)

#### 변수/함수명
- **컴포넌트**: `PascalCase` (예: `ProductCard`, `CartItem`)
- **함수**: `camelCase` (예: `fetchProducts`, `handleSubmit`)
- **상수**: `UPPER_SNAKE_CASE` (예: `API_BASE_URL`, `MAX_QUANTITY`)
- **Boolean**: `is`, `has`, `should` 접두사 (예: `isLoading`, `hasError`)

#### CSS 클래스명
- **kebab-case** 사용 (예: `product-card`, `cart-item`)
- **BEM 방식** 권장 (예: `product-card__title`, `product-card--featured`)

### 3. 컴포넌트 작성 규칙

#### 함수형 컴포넌트 사용
```jsx
// ✅ 올바른 예시
function ProductCard({ product, onAddToCart }) {
  const [quantity, setQuantity] = useState(1);
  
  return (
    <div className="product-card">
      {/* ... */}
    </div>
  );
}

export default ProductCard;
```

#### Props 구조 분해
```jsx
// ✅ 올바른 예시
function ProductCard({ product, onAddToCart }) {
  // product.name 대신 구조 분해
  const { name, price, imageUrl } = product;
}

// ❌ 잘못된 예시
function ProductCard(props) {
  return <div>{props.product.name}</div>;
}
```

#### PropTypes 또는 TypeScript
```jsx
// PropTypes 사용 (선택사항)
import PropTypes from 'prop-types';

ProductCard.propTypes = {
  product: PropTypes.shape({
    id: PropTypes.number.isRequired,
    name: PropTypes.string.isRequired,
    price: PropTypes.number.isRequired
  }).isRequired,
  onAddToCart: PropTypes.func.isRequired
};
```

### 4. Hooks 사용 규칙

#### Hooks 호출 순서
- Hooks는 항상 컴포넌트 최상위에서 호출
- 조건문, 반복문 안에서 호출 금지

```jsx
// ✅ 올바른 예시
function Component() {
  const [state, setState] = useState();
  const value = useContext(Context);
  
  useEffect(() => {
    // ...
  }, []);
  
  return <div>...</div>;
}

// ❌ 잘못된 예시
function Component() {
  if (condition) {
    const [state, setState] = useState(); // 조건문 안에서 호출 금지
  }
}
```

#### useEffect 의존성 배열
- 의존성 배열을 정확히 명시
- ESLint 경고 무시하지 않기

```jsx
// ✅ 올바른 예시
useEffect(() => {
  fetchProducts(categoryId);
}, [categoryId]); // categoryId 변경 시에만 실행

// ❌ 잘못된 예시
useEffect(() => {
  fetchProducts(categoryId);
}, []); // categoryId 변경 시 실행 안 됨
```

### 5. API 호출 규칙

#### Service 레이어 사용
```jsx
// ❌ 컴포넌트에서 직접 호출 금지
function ProductList() {
  useEffect(() => {
    axios.get('http://localhost:8080/api/products')
      .then(response => setProducts(response.data));
  }, []);
}

// ✅ Service 함수 사용
// services/productService.js
export const getProducts = async (page = 0, size = 20, category) => {
  const response = await api.get('/products', {
    params: { page, size, category }
  });
  return response.data;
};

// ProductList.jsx
function ProductList() {
  useEffect(() => {
    const fetchData = async () => {
      const data = await getProducts(0, 20);
      setProducts(data.content);
    };
    fetchData();
  }, []);
}
```

#### 에러 처리
```jsx
// ✅ 모든 API 호출에 에러 처리
const handleSubmit = async () => {
  setLoading(true);
  setError(null);
  
  try {
    const result = await createOrder(orderData);
    showSuccess('주문이 완료되었습니다');
    navigate('/orders');
  } catch (error) {
    if (error.response) {
      // 백엔드 에러
      setError(error.response.data.message);
    } else {
      // 네트워크 에러
      setError('네트워크 오류가 발생했습니다');
    }
  } finally {
    setLoading(false);
  }
};
```

#### 로딩 상태 관리
```jsx
// ✅ 로딩 상태 표시
function ProductList() {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        const data = await getProducts();
        setProducts(data.content);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);
  
  if (loading) return <Loading />;
  return <div>{/* 상품 목록 */}</div>;
}
```

### 6. 상태 관리 규칙

#### 로컬 상태 vs 전역 상태
- **로컬 상태 (useState)**: 컴포넌트 내부에서만 사용
- **전역 상태 (Context)**: 여러 컴포넌트에서 공유

```jsx
// 로컬 상태: 폼 입력, 모달 열림/닫힘
const [email, setEmail] = useState('');
const [isModalOpen, setIsModalOpen] = useState(false);

// 전역 상태: 인증 정보, 장바구니 개수
const { user, isAuthenticated } = useAuth();
```

#### Context 사용
```jsx
// ✅ Context 생성
const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [userId, setUserId] = useState(null);
  
  const login = async (email, password) => {
    const response = await userService.login(email, password);
    setUserId(response.userId);
    setUser(response.user);
    localStorage.setItem('userId', response.userId);
  };
  
  const logout = () => {
    setUserId(null);
    setUser(null);
    localStorage.removeItem('userId');
  };
  
  return (
    <AuthContext.Provider value={{ user, userId, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

// Custom Hook
export function useAuth() {
  return useContext(AuthContext);
}
```

### 7. 성능 최적화

#### React.memo 사용
```jsx
// ✅ 불필요한 리렌더링 방지
const ProductCard = React.memo(({ product, onAddToCart }) => {
  return <div>{/* ... */}</div>;
});
```

#### useCallback 사용
```jsx
// ✅ 함수 재생성 방지
const handleAddToCart = useCallback((productId, quantity) => {
  addToCart(productId, quantity);
}, [addToCart]);
```

#### 코드 스플리팅
```jsx
// ✅ 페이지별 lazy loading
const ProductDetail = lazy(() => import('./pages/ProductDetail'));
const Cart = lazy(() => import('./pages/Cart'));

<Suspense fallback={<Loading />}>
  <Routes>
    <Route path="/products/:id" element={<ProductDetail />} />
    <Route path="/cart" element={<Cart />} />
  </Routes>
</Suspense>
```

### 8. 스타일링 규칙

#### CSS Modules 사용 (권장)
```jsx
// ProductCard.module.css
.card { }
.title { }
.price { }

// ProductCard.jsx
import styles from './ProductCard.module.css';

function ProductCard() {
  return (
    <div className={styles.card}>
      <h3 className={styles.title}>상품명</h3>
      <p className={styles.price}>가격</p>
    </div>
  );
}
```

#### 조건부 클래스
```jsx
// ✅ 조건부 클래스 적용
<button className={`btn ${isPrimary ? 'btn-primary' : 'btn-secondary'}`}>
  클릭
</button>

// 또는 classnames 라이브러리 사용
import classNames from 'classnames';

<button className={classNames('btn', {
  'btn-primary': isPrimary,
  'btn-disabled': disabled
})}>
  클릭
</button>
```

### 9. 폼 처리

#### Controlled Components
```jsx
// ✅ Controlled Component 사용
function LoginForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  
  const handleSubmit = (e) => {
    e.preventDefault();
    login(email, password);
  };
  
  return (
    <form onSubmit={handleSubmit}>
      <input 
        value={email} 
        onChange={(e) => setEmail(e.target.value)} 
      />
      <input 
        type="password"
        value={password} 
        onChange={(e) => setPassword(e.target.value)} 
      />
      <button type="submit">로그인</button>
    </form>
  );
}
```

#### 입력 검증
```jsx
// ✅ 실시간 검증
const [emailError, setEmailError] = useState('');

const validateEmail = (email) => {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!regex.test(email)) {
    setEmailError('올바른 이메일 형식이 아닙니다');
    return false;
  }
  setEmailError('');
  return true;
};

<Input 
  value={email}
  onChange={(e) => {
    setEmail(e.target.value);
    validateEmail(e.target.value);
  }}
  error={emailError}
/>
```

### 10. 에러 처리

#### 에러 바운더리
```jsx
// ErrorBoundary.jsx
class ErrorBoundary extends React.Component {
  state = { hasError: false };
  
  static getDerivedStateFromError(error) {
    return { hasError: true };
  }
  
  componentDidCatch(error, errorInfo) {
    console.error('Error:', error, errorInfo);
  }
  
  render() {
    if (this.state.hasError) {
      return <h1>문제가 발생했습니다.</h1>;
    }
    return this.props.children;
  }
}
```

#### API 에러 처리
```jsx
// ✅ 통일된 에러 처리
const handleApiError = (error) => {
  if (error.response) {
    // 백엔드 에러 응답
    const { code, message, status } = error.response.data;
    
    switch (code) {
      case 'INVALID_CREDENTIALS':
        return '이메일 또는 비밀번호가 일치하지 않습니다';
      case 'INSUFFICIENT_STOCK':
        return message; // 백엔드에서 상세 메시지 제공
      default:
        return message || '오류가 발생했습니다';
    }
  } else if (error.request) {
    // 네트워크 에러
    return '서버에 연결할 수 없습니다';
  } else {
    return '요청 처리 중 오류가 발생했습니다';
  }
};
```

### 11. 라우팅 규칙

#### Protected Route 구현
```jsx
// ✅ 인증 필요한 페이지 보호
function ProtectedRoute({ children }) {
  const { isAuthenticated } = useAuth();
  const location = useLocation();
  
  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }
  
  return children;
}

// App.jsx
<Routes>
  <Route path="/login" element={<Login />} />
  <Route path="/cart" element={
    <ProtectedRoute>
      <Cart />
    </ProtectedRoute>
  } />
</Routes>
```

### 12. 코드 품질 원칙

#### 컴포넌트는 작게
- **한 컴포넌트는 100줄 이내** 권장
- 복잡하면 더 작은 컴포넌트로 분리

```jsx
// ❌ 너무 큰 컴포넌트
function ProductPage() {
  // 200줄의 코드...
}

// ✅ 작은 컴포넌트로 분리
function ProductPage() {
  return (
    <div>
      <ProductInfo product={product} />
      <ProductActions onAddToCart={handleAddToCart} />
      <ProductReviews reviews={reviews} />
    </div>
  );
}
```

#### Early Return 사용
```jsx
// ✅ Early Return으로 가독성 향상
function ProductList({ products }) {
  if (loading) return <Loading />;
  if (error) return <Error message={error} />;
  if (products.length === 0) return <Empty />;
  
  return (
    <div>
      {products.map(product => <ProductCard key={product.id} product={product} />)}
    </div>
  );
}
```

#### Key 속성 사용
```jsx
// ✅ 고유한 key 사용
{products.map(product => (
  <ProductCard key={product.id} product={product} />
))}

// ❌ index를 key로 사용 금지 (순서 변경 시 문제)
{products.map((product, index) => (
  <ProductCard key={index} product={product} />
))}
```

### 13. 접근성 (Accessibility)

#### 시맨틱 HTML
```jsx
// ✅ 시맨틱 태그 사용
<nav>
  <ul>
    <li><a href="/">홈</a></li>
  </ul>
</nav>

<main>
  <article>
    <h1>상품명</h1>
    <p>설명</p>
  </article>
</main>

// ❌ div 남용
<div>
  <div>
    <div>홈</div>
  </div>
</div>
```

#### ARIA 속성
```jsx
// ✅ 적절한 ARIA 속성
<button 
  aria-label="장바구니에 추가"
  onClick={handleAddToCart}
>
  <CartIcon />
</button>

<input 
  type="text"
  aria-invalid={hasError}
  aria-describedby="email-error"
/>
{hasError && <span id="email-error">{error}</span>}
```

#### 키보드 네비게이션
```jsx
// ✅ 키보드 이벤트 처리
<div 
  role="button"
  tabIndex={0}
  onClick={handleClick}
  onKeyPress={(e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      handleClick();
    }
  }}
>
  클릭 가능한 영역
</div>
```

### 14. 유틸리티 함수

#### 포맷터
```javascript
// utils/formatters.js

// 가격 포맷
export const formatPrice = (price) => {
  return price.toLocaleString('ko-KR') + '원';
};

// 날짜 포맷
export const formatDate = (dateString) => {
  const date = new Date(dateString);
  return date.toLocaleDateString('ko-KR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });
};

// 주문 상태 텍스트
export const getStatusText = (status) => {
  const statusMap = {
    PENDING: '대기중',
    CONFIRMED: '확인됨',
    CANCELLED: '취소됨'
  };
  return statusMap[status] || status;
};
```

### 15. Git 커밋 규칙

#### 커밋 메시지 형식
```
<type>: <subject>

<body>
```

#### Type 종류
- `feat`: 새로운 기능 추가
- `fix`: 버그 수정
- `style`: UI/스타일 변경
- `refactor`: 코드 리팩토링
- `docs`: 문서 수정
- `chore`: 빌드 설정, 패키지 수정

#### 예시
```
feat: Add product list page with category filter

- Implement ProductList component
- Add category tabs
- Integrate with product API
- Add pagination
```

### 16. 주석 작성

#### 컴포넌트 주석
```jsx
/**
 * 상품 카드 컴포넌트
 * 
 * @param {Object} product - 상품 정보
 * @param {Function} onAddToCart - 장바구니 추가 핸들러
 */
function ProductCard({ product, onAddToCart }) {
  // ...
}
```

#### 복잡한 로직에만 주석
```jsx
// ✅ Why를 설명
// 주문 시점의 가격을 저장하기 위해 별도로 관리
const orderPrice = product.price;

// ❌ What을 설명 (코드로 충분히 이해 가능)
// 가격을 설정한다
const price = product.price;
```

### 17. 보안 규칙

#### XSS 방지
```jsx
// ✅ React는 기본적으로 XSS 방지
<div>{userInput}</div> // 자동 이스케이프

// ❌ dangerouslySetInnerHTML 사용 금지 (필요시에만)
<div dangerouslySetInnerHTML={{ __html: userInput }} />
```

#### 민감 정보 관리
```javascript
// ✅ 환경 변수 사용
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL;

// ❌ 하드코딩 금지
const API_KEY = 'secret-key-123'; // 절대 금지
```

## 작업 체크리스트

각 기능 구현 시 다음 체크리스트를 확인한다:

- [ ] API Service 함수 작성 완료
- [ ] 컴포넌트 구현 완료
- [ ] 로딩 상태 처리 완료
- [ ] 에러 처리 완료
- [ ] 브라우저 테스트 성공
- [ ] 반응형 디자인 확인
- [ ] 콘솔 에러/경고 없음
- [ ] Git 커밋 완료

## 주의사항

- 이 규칙은 프로젝트 진행 중 수정되거나 추가될 수 있음
- 규칙 변경 시 이 문서를 업데이트할 것
- 모든 팀원은 이 규칙을 준수할 것

---

## 변경 이력

| 날짜 | 변경 내용 | 작성자 |
|------|----------|--------|
| 2025-12-10 | 초기 작성 - React 모범사례 기반 규칙 정의 | - |
| 2025-12-10 | Playwright 브라우저 자동화 테스트 방법 추가 | - |
