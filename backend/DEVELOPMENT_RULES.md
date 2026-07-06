# 개발 작업 규칙 (Development Rules)

## 기능 구현 순서

### 1. 구현 순서
기능 구현 시 다음 순서를 따른다:
1. **DTO (Data Transfer Object)** 작성
2. **Service** 레이어 구현
3. **Controller** 레이어 구현

### 2. 테스트 및 검증
Controller 구현 완료 후 다음 절차를 수행한다:
1. **HTTP Client 파일 작성** (`.http` 파일)
2. **Gradle 빌드 수행** (`./gradlew build`)
3. **로컬 프로세스 실행** (`./gradlew bootRun`)
4. **HTTP Client 실행**하여 기능 정상 작동 확인

### 3. 데이터베이스
- **로컬 개발 환경**: H2 인메모리 데이터베이스 사용
- **운영 환경**: MySQL (추후 전환)

## 코드 작성 규칙

### 1. 패키지 구조
**Layer별 분리 + Domain별 파일 구성**

```
src/main/java/com/example/ecommercedemo/
├── controller/
│   ├── ProductController.java
│   ├── OrderController.java
│   └── UserController.java
├── service/
│   ├── ProductService.java
│   ├── OrderService.java
│   └── UserService.java
├── repository/
│   ├── ProductRepository.java
│   ├── OrderRepository.java
│   └── UserRepository.java
├── dto/
│   ├── ProductDto.java
│   ├── OrderDto.java
│   └── UserDto.java
├── entity/
│   ├── Product.java
│   ├── Order.java
│   ├── OrderItem.java
│   └── User.java
└── exception/
    └── GlobalExceptionHandler.java
```

#### 패키지별 용도

- **controller**: REST API 엔드포인트 정의, HTTP 요청/응답 처리
  - DTO만 사용 (Entity 직접 노출 금지)
  - 요청 검증 (`@Valid`)
  - Service 호출

- **service**: 비즈니스 로직 구현, 트랜잭션 관리
  - Entity ↔ DTO 변환 수행
  - Repository 호출
  - 비즈니스 검증 및 예외 처리

- **dto**: 계층 간 데이터 전달 객체 (Data Transfer Object)
  - API 요청/응답 구조 정의
  - Validation 어노테이션 포함
  - Entity와 완전히 분리

- **entity**: 데이터베이스 테이블과 직접 매핑되는 JPA Entity
  - 데이터베이스 구조 반영
  - 비즈니스 메서드 포함
  - Controller에 직접 노출 금지

- **repository**: 데이터 접근 계층
  - Spring Data JPA 인터페이스
  - 커스텀 쿼리 메서드

- **exception**: 예외 처리
  - Custom Exception 정의
  - GlobalExceptionHandler

#### Entity와 DTO 분리 원칙

**중요: Entity를 Controller에서 직접 사용하지 않는다**

```java
// ❌ 잘못된 예시 - Entity를 직접 반환
@GetMapping("/{id}")
public Product selectProduct(@PathVariable Long id) {
    return productService.selectProduct(id);  // Entity 직접 노출
}

// ✅ 올바른 예시 - DTO로 변환하여 반환
@GetMapping("/{id}")
public ProductDto selectProduct(@PathVariable Long id) {
    return productService.selectProduct(id);  // DTO 반환
}
```

**Service에서 Entity ↔ DTO 변환**

```java
@Service
public class ProductService {
    
    public ProductDto selectProduct(Long id) {
        Product product = productRepository.findById(id)
            .orElseThrow(() -> new ProductNotFoundException("상품을 찾을 수 없습니다"));
        
        // Entity → DTO 변환
        return ProductDto.from(product);
    }
    
    public ProductDto insertProduct(ProductCreateDto dto) {
        // DTO → Entity 변환
        Product product = Product.builder()
            .name(dto.getName())
            .price(dto.getPrice())
            .stockQuantity(dto.getStockQuantity())
            .build();
        
        Product savedProduct = productRepository.save(product);
        
        // Entity → DTO 변환
        return ProductDto.from(savedProduct);
    }
}
```

**DTO에 변환 메서드 제공**

```java
@Getter
@NoArgsConstructor
public class ProductDto {
    private Long id;
    private String name;
    private BigDecimal price;
    private Integer stockQuantity;
    
    // Entity → DTO 변환 정적 메서드
    public static ProductDto from(Product product) {
        ProductDto dto = new ProductDto();
        dto.id = product.getId();
        dto.name = product.getName();
        dto.price = product.getPrice();
        dto.stockQuantity = product.getStockQuantity();
        return dto;
    }
}
```

### 2. 네이밍 컨벤션

#### 클래스명
- **Controller**: `{Domain}Controller` (예: `OrderController`, `ProductController`)
- **Service**: `{Domain}Service` (예: `OrderService`, `ProductService`)
- **Repository**: `{Domain}Repository` (예: `OrderRepository`, `ProductRepository`)
- **DTO**: `{Domain}Dto` 또는 `{Domain}{Purpose}Dto` (예: `OrderDto`, `ProductCreateDto`)
- **Entity**: `{Domain}` (예: `Order`, `Product`, `User`)

#### 메서드명
**행위 기반 명명 규칙 사용**

- **등록/생성**: `insert{Domain}` (예: `insertProduct`, `insertOrder`)
- **조회 (단건)**: `select{Domain}` (예: `selectProduct`, `selectOrder`)
- **조회 (목록)**: `select{Domain}List` (예: `selectProductList`, `selectOrderList`)
- **수정**: `update{Domain}` (예: `updateProduct`, `updateOrder`)
- **삭제**: `delete{Domain}` (예: `deleteProduct`, `deleteOrder`)
- **특정 행위**: `{action}{Domain}` (예: `cancelOrder`, `confirmOrder`)

**예시:**
```java
// ProductService
public ProductDto insertProduct(ProductCreateDto dto) { }
public ProductDto selectProduct(Long id) { }
public List<ProductDto> selectProductList(Pageable pageable) { }
public ProductDto updateProduct(Long id, ProductUpdateDto dto) { }
public void deleteProduct(Long id) { }

// OrderService
public OrderDto insertOrder(OrderCreateDto dto) { }
public OrderDto selectOrder(Long id) { }
public List<OrderDto> selectOrderList(Long userId, Pageable pageable) { }
public OrderDto cancelOrder(Long id) { }
```

#### 변수명
- **camelCase** 사용
- 의미 있는 이름 사용 (약어 지양)
- Boolean 타입: `is`, `has`, `can` 접두사 사용 (예: `isDeleted`, `hasStock`)

### 3. DTO 작성 규칙
- 요청/응답 DTO 분리
- `{Domain}CreateDto`: 생성 요청
- `{Domain}UpdateDto`: 수정 요청
- `{Domain}Dto`: 응답 (기본)
- `{Domain}ListDto`: 목록 응답 (필요시)

### 4. 예외 처리 규칙
**Clean Code 원칙: 예외를 사용하여 오류를 처리하라**

#### Custom Exception 정의
```java
// 비즈니스 예외의 기본 클래스
public class BusinessException extends RuntimeException {
    private final ErrorCode errorCode;
}

// 도메인별 예외
public class ProductNotFoundException extends BusinessException { }
public class InsufficientStockException extends BusinessException { }
```

#### GlobalExceptionHandler
- 모든 예외를 한 곳에서 처리
- 일관된 에러 응답 형식 제공
- 예외 로깅 수행

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ErrorResponse> handleBusinessException(BusinessException e) {
        // 에러 로깅 및 응답 반환
    }
}
```

#### 에러 응답 형식
```json
{
  "code": "PRODUCT_NOT_FOUND",
  "message": "상품을 찾을 수 없습니다.",
  "timestamp": "2025-12-09T17:30:00"
}
```

### 5. API 응답 형식
**Effective Java Item 54: null이 아닌, 빈 컬렉션이나 배열을 반환하라**

#### 성공 응답
- 단순 데이터 반환 (불필요한 Wrapper 지양)
- 컬렉션은 빈 리스트 반환 (null 반환 금지)

```java
// 단건 조회
@GetMapping("/{id}")
public ProductDto selectProduct(@PathVariable Long id) {
    return productService.selectProduct(id);
}

// 목록 조회 (페이징)
@GetMapping
public Page<ProductDto> selectProductList(Pageable pageable) {
    return productService.selectProductList(pageable);
}
```

#### 실패 응답
- GlobalExceptionHandler에서 통일된 형식으로 처리
- HTTP 상태 코드와 에러 코드 명확히 구분

### 6. 트랜잭션 규칙
**Effective Java Item 76: 가능한 한 실패 원자적으로 만들라**

#### 기본 원칙
- `@Transactional`은 **Service 레이어에만** 적용
- Controller, Repository에는 사용 금지
- 조회 메서드는 `@Transactional(readOnly = true)` 사용

```java
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)  // 클래스 레벨: 기본 readOnly
public class ProductService {
    
    @Transactional  // 쓰기 작업만 readOnly 해제
    public ProductDto insertProduct(ProductCreateDto dto) {
        // ...
    }
    
    public ProductDto selectProduct(Long id) {
        // readOnly 트랜잭션
    }
}
```

### 7. Validation 규칙
**Clean Code: 경계 조건을 캡슐화하라**

#### Bean Validation 사용
- DTO에 `@Valid` 어노테이션 적용
- Controller에서 `@Valid` 검증

```java
public class ProductCreateDto {
    @NotBlank(message = "상품명은 필수입니다")
    @Size(max = 100, message = "상품명은 100자를 초과할 수 없습니다")
    private String name;
    
    @NotNull(message = "가격은 필수입니다")
    @Positive(message = "가격은 0보다 커야 합니다")
    private BigDecimal price;
}

@PostMapping
public ProductDto insertProduct(@Valid @RequestBody ProductCreateDto dto) {
    return productService.insertProduct(dto);
}
```

#### 비즈니스 검증
- Service 레이어에서 수행
- 명확한 예외 메시지 제공

```java
public ProductDto insertProduct(ProductCreateDto dto) {
    if (productRepository.existsByName(dto.getName())) {
        throw new DuplicateProductNameException("이미 존재하는 상품명입니다");
    }
    // ...
}
```

### 8. Entity 작성 규칙
**Effective Java Item 17: 변경 가능성을 최소화하라**

#### BaseEntity 사용
```java
@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
public abstract class BaseEntity {
    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime createdAt;
    
    @LastModifiedDate
    private LocalDateTime updatedAt;
}
```

#### Entity 작성 원칙
- **불변성 최대화**: Setter 사용 금지
- **생성자 또는 빌더 패턴** 사용
- **비즈니스 로직은 Entity에** 위치

```java
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Product extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String name;
    private BigDecimal price;
    private Integer stockQuantity;
    
    @Builder
    private Product(String name, BigDecimal price, Integer stockQuantity) {
        this.name = name;
        this.price = price;
        this.stockQuantity = stockQuantity;
    }
    
    // 비즈니스 메서드
    public void decreaseStock(int quantity) {
        if (this.stockQuantity < quantity) {
            throw new InsufficientStockException("재고가 부족합니다");
        }
        this.stockQuantity -= quantity;
    }
    
    public void updateInfo(String name, BigDecimal price) {
        this.name = name;
        this.price = price;
    }
}
```

#### 연관관계 매핑
- **지연 로딩(LAZY) 기본 사용**
- 양방향 연관관계는 신중히 사용
- 연관관계 편의 메서드 제공

```java
@Entity
public class Order extends BaseEntity {
    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<OrderItem> orderItems = new ArrayList<>();
    
    // 연관관계 편의 메서드
    public void addOrderItem(OrderItem orderItem) {
        orderItems.add(orderItem);
        orderItem.setOrder(this);
    }
}
```

### 9. Git 커밋 규칙
**Clean Code: 의미 있는 이름을 사용하라**

#### 커밋 메시지 형식
```
<type>: <subject>

<body>
```

#### Type 종류
- `feat`: 새로운 기능 추가
- `fix`: 버그 수정
- `docs`: 문서 수정
- `refactor`: 코드 리팩토링 (기능 변경 없음)
- `test`: 테스트 코드 추가/수정
- `chore`: 빌드 설정, 패키지 매니저 수정

#### 예시
```
feat: Add product creation API

- Add ProductCreateDto
- Add ProductService.insertProduct method
- Add ProductController.insertProduct endpoint
```

#### 커밋 단위
- **기능 단위로 커밋** (너무 작거나 크지 않게)
- 빌드가 성공하는 상태로 커밋
- 하나의 커밋은 하나의 목적

### 10. 로깅 규칙
**Clean Code: 의도를 분명히 밝혀라**

#### 로그 레벨 사용 기준
- **ERROR**: 예외 발생, 즉시 조치 필요
- **WARN**: 잠재적 문제, 주의 필요
- **INFO**: 중요한 비즈니스 로직 실행 (API 호출, 주요 상태 변경)
- **DEBUG**: 개발 중 디버깅 정보

#### 로깅 위치
```java
@Slf4j
@Service
public class OrderService {
    
    @Transactional
    public OrderDto insertOrder(OrderCreateDto dto) {
        log.info("주문 생성 시작 - userId: {}, itemCount: {}", 
                 dto.getUserId(), dto.getItems().size());
        
        try {
            // 비즈니스 로직
            Order order = createOrder(dto);
            log.info("주문 생성 완료 - orderId: {}, totalAmount: {}", 
                     order.getId(), order.getTotalAmount());
            return OrderDto.from(order);
            
        } catch (InsufficientStockException e) {
            log.error("재고 부족으로 주문 실패 - userId: {}, productId: {}", 
                      dto.getUserId(), e.getProductId(), e);
            throw e;
        }
    }
}
```

#### 로깅 원칙
- **민감 정보 로깅 금지** (비밀번호, 개인정보)
- **구조화된 로깅** (key-value 형식)
- **예외는 최상위에서 로깅** (중복 로깅 방지)
- **성능에 영향 없도록** (DEBUG 레벨 적절히 사용)

### 11. 코드 품질 원칙
**Clean Code & Effective Java 핵심 원칙**

#### 메서드 작성
- **한 가지 일만 수행** (Single Responsibility)
- **작게 유지** (20줄 이내 권장)
- **의미 있는 이름** 사용
- **인수는 적을수록 좋음** (3개 이하 권장)

#### 주석
- **코드로 의도를 표현** (주석보다 명확한 코드)
- **Why를 설명** (What이 아닌)
- **TODO 주석은 반드시 처리**

#### 매직 넘버 금지
```java
// Bad
if (order.getStatus() == 1) { }

// Good
if (order.getStatus() == OrderStatus.PENDING) { }
```

#### Null 처리
- **Optional 적극 활용**
- **null 반환 금지** (빈 컬렉션 반환)
- **null 체크보다 예외 처리**

## 작업 체크리스트

각 기능 구현 시 다음 체크리스트를 확인한다:

- [ ] DTO 작성 완료
- [ ] Service 구현 완료
- [ ] Controller 구현 완료
- [ ] HTTP Client 파일 작성 완료
- [ ] Gradle 빌드 성공
- [ ] 로컬 실행 성공
- [ ] HTTP Client 테스트 성공

## 주의사항

- 이 규칙은 프로젝트 진행 중 수정되거나 추가될 수 있음
- 규칙 변경 시 이 문서를 업데이트할 것
- 모든 팀원은 이 규칙을 준수할 것

---

## 변경 이력

| 날짜 | 변경 내용 | 작성자 |
|------|----------|--------|
| 2025-12-09 | 초기 작성 | - |
| 2025-12-09 | 패키지 구조 및 네이밍 컨벤션 규칙 추가 | - |
| 2025-12-09 | Clean Code & Effective Java 기반 상세 규칙 추가 | - |
| 2025-12-09 | 패키지별 용도 및 Entity-DTO 분리 원칙 추가 | - |
