# Development Rules

## Implementation Order

### 1. Implementation Sequence
Follow this order when implementing features:
1. **DTO (Data Transfer Object)** creation
2. **Service** layer implementation
3. **Controller** layer implementation

### 2. Testing and Verification
After completing Controller implementation, perform the following:
1. **Create HTTP Client file** (`.http` file)
2. **Execute Gradle build** (`./gradlew build`)
3. **Run local process** (`./gradlew bootRun`)
4. **Execute HTTP Client** to verify functionality

### 3. Database
- **Local Development**: H2 in-memory database
- **Production**: MySQL (to be migrated later)

## Code Writing Rules

### 1. Package Structure
**Layer-based separation + Domain-based file organization**

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

#### Package Purposes

- **controller**: REST API endpoint definition, HTTP request/response handling
  - Use DTO only (never expose Entity directly)
  - Request validation (`@Valid`)
  - Service invocation

- **service**: Business logic implementation, transaction management
  - Perform Entity ↔ DTO conversion
  - Repository invocation
  - Business validation and exception handling

- **dto**: Data Transfer Objects for inter-layer communication
  - Define API request/response structure
  - Include validation annotations
  - Completely separated from Entity

- **entity**: JPA Entities directly mapped to database tables
  - Reflect database structure
  - Include business methods
  - Never expose directly to Controller

- **repository**: Data access layer
  - Spring Data JPA interfaces
  - Custom query methods

- **exception**: Exception handling
  - Custom Exception definitions
  - GlobalExceptionHandler

#### Entity and DTO Separation Principle

**Important: Never use Entity directly in Controller**

```java
// ❌ Wrong - Returning Entity directly
@GetMapping("/{id}")
public Product selectProduct(@PathVariable Long id) {
    return productService.selectProduct(id);  // Direct Entity exposure
}

// ✅ Correct - Convert to DTO and return
@GetMapping("/{id}")
public ProductDto selectProduct(@PathVariable Long id) {
    return productService.selectProduct(id);  // Return DTO
}
```

**Entity ↔ DTO Conversion in Service**

```java
@Service
public class ProductService {
    
    public ProductDto selectProduct(Long id) {
        Product product = productRepository.findById(id)
            .orElseThrow(() -> new ProductNotFoundException("Product not found"));
        
        // Entity → DTO conversion
        return ProductDto.from(product);
    }
    
    public ProductDto insertProduct(ProductCreateDto dto) {
        // DTO → Entity conversion
        Product product = Product.builder()
            .name(dto.getName())
            .price(dto.getPrice())
            .stockQuantity(dto.getStockQuantity())
            .build();
        
        Product savedProduct = productRepository.save(product);
        
        // Entity → DTO conversion
        return ProductDto.from(savedProduct);
    }
}
```

**Provide Conversion Methods in DTO**

```java
@Getter
@NoArgsConstructor
public class ProductDto {
    private Long id;
    private String name;
    private BigDecimal price;
    private Integer stockQuantity;
    
    // Static method for Entity → DTO conversion
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

### 2. Naming Conventions

#### Class Names
- **Controller**: `{Domain}Controller` (e.g., `OrderController`, `ProductController`)
- **Service**: `{Domain}Service` (e.g., `OrderService`, `ProductService`)
- **Repository**: `{Domain}Repository` (e.g., `OrderRepository`, `ProductRepository`)
- **DTO**: `{Domain}Dto` or `{Domain}{Purpose}Dto` (e.g., `OrderDto`, `ProductCreateDto`)
- **Entity**: `{Domain}` (e.g., `Order`, `Product`, `User`)

#### Method Names
**Action-based naming convention**

- **Create/Insert**: `insert{Domain}` (e.g., `insertProduct`, `insertOrder`)
- **Read (Single)**: `select{Domain}` (e.g., `selectProduct`, `selectOrder`)
- **Read (List)**: `select{Domain}List` (e.g., `selectProductList`, `selectOrderList`)
- **Update**: `update{Domain}` (e.g., `updateProduct`, `updateOrder`)
- **Delete**: `delete{Domain}` (e.g., `deleteProduct`, `deleteOrder`)
- **Specific Action**: `{action}{Domain}` (e.g., `cancelOrder`, `confirmOrder`)

**Examples:**
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

#### Variable Names
- Use **camelCase**
- Use meaningful names (avoid abbreviations)
- Boolean types: use `is`, `has`, `can` prefix (e.g., `isDeleted`, `hasStock`)

### 3. DTO Writing Rules
- Separate request/response DTOs
- `{Domain}CreateDto`: Create request
- `{Domain}UpdateDto`: Update request
- `{Domain}Dto`: Response (default)
- `{Domain}ListDto`: List response (if needed)

### 4. Exception Handling Rules
**Clean Code Principle: Use exceptions for error handling**

#### Custom Exception Definition
```java
// Base class for business exceptions
public class BusinessException extends RuntimeException {
    private final ErrorCode errorCode;
}

// Domain-specific exceptions
public class ProductNotFoundException extends BusinessException { }
public class InsufficientStockException extends BusinessException { }
```

#### GlobalExceptionHandler
- Handle all exceptions in one place
- Provide consistent error response format
- Perform exception logging

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ErrorResponse> handleBusinessException(BusinessException e) {
        // Log error and return response
    }
}
```

#### Error Response Format
```json
{
  "code": "PRODUCT_NOT_FOUND",
  "message": "Product not found",
  "timestamp": "2025-12-09T17:30:00"
}
```

### 5. API Response Format
**Effective Java Item 54: Return empty collections or arrays, not nulls**

#### Success Response
- Return simple data (avoid unnecessary wrappers)
- Return empty list for collections (never return null)

```java
// Single item
@GetMapping("/{id}")
public ProductDto selectProduct(@PathVariable Long id) {
    return productService.selectProduct(id);
}

// List (with pagination)
@GetMapping
public Page<ProductDto> selectProductList(Pageable pageable) {
    return productService.selectProductList(pageable);
}
```

#### Failure Response
- Handle with unified format in GlobalExceptionHandler
- Clearly distinguish HTTP status codes and error codes

### 6. Transaction Rules
**Effective Java Item 76: Strive for failure atomicity**

#### Basic Principles
- Apply `@Transactional` **only to Service layer**
- Do not use in Controller or Repository
- Use `@Transactional(readOnly = true)` for read methods

```java
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)  // Class level: default readOnly
public class ProductService {
    
    @Transactional  // Remove readOnly for write operations
    public ProductDto insertProduct(ProductCreateDto dto) {
        // ...
    }
    
    public ProductDto selectProduct(Long id) {
        // readOnly transaction
    }
}
```

### 7. Validation Rules
**Clean Code: Encapsulate boundary conditions**

#### Bean Validation Usage
- Apply `@Valid` annotation to DTOs
- Validate with `@Valid` in Controller

```java
public class ProductCreateDto {
    @NotBlank(message = "Product name is required")
    @Size(max = 100, message = "Product name cannot exceed 100 characters")
    private String name;
    
    @NotNull(message = "Price is required")
    @Positive(message = "Price must be greater than 0")
    private BigDecimal price;
}

@PostMapping
public ProductDto insertProduct(@Valid @RequestBody ProductCreateDto dto) {
    return productService.insertProduct(dto);
}
```

#### Business Validation
- Perform in Service layer
- Provide clear exception messages

```java
public ProductDto insertProduct(ProductCreateDto dto) {
    if (productRepository.existsByName(dto.getName())) {
        throw new DuplicateProductNameException("Product name already exists");
    }
    // ...
}
```

### 8. Entity Writing Rules
**Effective Java Item 17: Minimize mutability**

#### BaseEntity Usage
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

#### Entity Writing Principles
- **Maximize immutability**: No setters
- Use **constructor or builder pattern**
- **Business logic in Entity**

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
    
    // Business methods
    public void decreaseStock(int quantity) {
        if (this.stockQuantity < quantity) {
            throw new InsufficientStockException("Insufficient stock");
        }
        this.stockQuantity -= quantity;
    }
    
    public void updateInfo(String name, BigDecimal price) {
        this.name = name;
        this.price = price;
    }
}
```

#### Relationship Mapping
- **Use LAZY loading by default**
- Use bidirectional relationships carefully
- Provide convenience methods for relationships

```java
@Entity
public class Order extends BaseEntity {
    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<OrderItem> orderItems = new ArrayList<>();
    
    // Convenience method for relationship
    public void addOrderItem(OrderItem orderItem) {
        orderItems.add(orderItem);
        orderItem.setOrder(this);
    }
}
```

### 9. Git Commit Rules
**Clean Code: Use meaningful names**

#### Commit Message Format
```
<type>: <subject>

<body>
```

#### Type Categories
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring (no functionality change)
- `test`: Test code addition/modification
- `chore`: Build configuration, package manager changes

#### Examples
```
feat: Add product creation API

- Add ProductCreateDto
- Add ProductService.insertProduct method
- Add ProductController.insertProduct endpoint
```

#### Commit Units
- **Commit by feature** (not too small or large)
- Commit in buildable state
- One commit, one purpose

### 10. Logging Rules
**Clean Code: Make your intentions clear**

#### Log Level Usage
- **ERROR**: Exception occurred, immediate action required
- **WARN**: Potential issue, attention needed
- **INFO**: Important business logic execution (API calls, major state changes)
- **DEBUG**: Debugging information during development

#### Logging Locations
```java
@Slf4j
@Service
public class OrderService {
    
    @Transactional
    public OrderDto insertOrder(OrderCreateDto dto) {
        log.info("Order creation started - userId: {}, itemCount: {}", 
                 dto.getUserId(), dto.getItems().size());
        
        try {
            // Business logic
            Order order = createOrder(dto);
            log.info("Order creation completed - orderId: {}, totalAmount: {}", 
                     order.getId(), order.getTotalAmount());
            return OrderDto.from(order);
            
        } catch (InsufficientStockException e) {
            log.error("Order failed due to insufficient stock - userId: {}, productId: {}", 
                      dto.getUserId(), e.getProductId(), e);
            throw e;
        }
    }
}
```

#### Logging Principles
- **No sensitive information** (passwords, personal data)
- **Structured logging** (key-value format)
- **Log exceptions at top level** (avoid duplicate logging)
- **No performance impact** (use DEBUG level appropriately)

### 11. Code Quality Principles
**Clean Code & Effective Java Core Principles**

#### Method Writing
- **Do one thing** (Single Responsibility)
- **Keep it small** (recommended under 20 lines)
- Use **meaningful names**
- **Fewer arguments** (recommended 3 or fewer)

#### Comments
- **Express intent with code** (clear code over comments)
- **Explain Why** (not What)
- **Always handle TODO comments**

#### No Magic Numbers
```java
// Bad
if (order.getStatus() == 1) { }

// Good
if (order.getStatus() == OrderStatus.PENDING) { }
```

#### Null Handling
- **Use Optional actively**
- **Never return null** (return empty collections)
- **Exception handling over null checks**

## Work Checklist

Check the following for each feature implementation:

- [ ] DTO creation completed
- [ ] Service implementation completed
- [ ] Controller implementation completed
- [ ] HTTP Client file created
- [ ] Gradle build successful
- [ ] Local execution successful
- [ ] HTTP Client test successful

## Notes

- These rules may be modified or added during project progress
- Update this document when rules change
- All team members must follow these rules

---

## Change History

| Date | Changes | Author |
|------|---------|--------|
| 2025-12-09 | Initial creation | - |
| 2025-12-09 | Added package structure and naming conventions | - |
| 2025-12-09 | Added detailed rules based on Clean Code & Effective Java | - |
| 2025-12-09 | Added package purposes and Entity-DTO separation principle | - |
