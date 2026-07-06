# E-Commerce Demo Application Requirements Specification

## 1. Project Overview

### 1.1 Purpose
- Demo e-commerce application for infrastructure-level modernization demonstration
- Demonstrate Monolithic → Microservices architecture transformation
- Demonstrate EC2-based → Container-based (ECS) transformation
- Demonstrate Self-managed → AWS Managed Services transformation

### 1.2 Tech Stack
- **Language/Framework**: Java 17, Spring Boot 4.0.0
- **Build Tool**: Gradle 8.14
- **Database**: H2 (Development) → MySQL (Production)
- **ORM**: Spring Data JPA

## 2. Functional Requirements

### 2.1 Product Management (Product Service)

#### 2.1.1 Create Product
- **Description**: Register a new product
- **Input**:
  - Product name (Required, max 100 chars)
  - Description (Optional, max 1000 chars)
  - Price (Required, positive number)
  - Stock quantity (Required, >= 0)
  - Category (Required)
  - Image URL (Optional)
- **Output**: Created product information (including product ID)
- **Validation**:
  - Product name must be unique
  - Price must be greater than 0
  - Stock quantity must be >= 0

#### 2.1.2 List Products
- **Description**: Retrieve list of registered products
- **Input**:
  - Page number (Default: 0)
  - Page size (Default: 20, Max: 100)
  - Category filter (Optional)
  - Sort criteria (Default: latest)
- **Output**: Paginated product list
- **Features**:
  - Filter by category
  - Sort by price/latest

#### 2.1.3 Get Product Details
- **Description**: Retrieve detailed information of a specific product
- **Input**: Product ID
- **Output**: Product details
- **Exception**: 404 error if product ID doesn't exist

#### 2.1.4 Update Product
- **Description**: Update existing product information
- **Input**:
  - Product ID
  - Fields to update (partial update allowed)
- **Output**: Updated product information
- **Validation**: Same validation rules as product creation

#### 2.1.5 Delete Product
- **Description**: Delete a product (Soft Delete)
- **Input**: Product ID
- **Output**: Deletion success message
- **Constraint**: Cannot delete products with order history

### 2.2 Order Management (Order Service)

#### 2.2.1 Create Order
- **Description**: Create a new order
- **Input**:
  - User ID (Required)
  - Order items list (Required, minimum 1 item)
    - Product ID
    - Quantity
- **Output**: Created order information (including order ID and total amount)
- **Processing Logic**:
  1. Check product stock
  2. Deduct stock
  3. Calculate order total
  4. Create order (Status: PENDING)
- **Validation**:
  - Order fails if insufficient stock (specify which product)
  - Order fails if product ID doesn't exist
- **Transaction**: Stock deduction and order creation must be atomic

#### 2.2.2 Create Order from Cart
- **Description**: Create order from cart items
- **Input**: User ID (header)
- **Output**: Created order information
- **Processing Logic**:
  1. Retrieve cart
  2. Convert cart items to order
  3. Create order (reuse existing logic)
  4. Clear cart on success
- **Validation**: Fails if cart is empty
- **Transaction**: Order creation and cart clearing must be atomic

#### 2.2.3 List Orders
- **Description**: Retrieve user's order list
- **Input**:
  - User ID (Required)
  - Page number (Default: 0)
  - Page size (Default: 20)
  - Order status filter (Optional)
- **Output**: Paginated order list
- **Features**: Filter by order status

#### 2.2.4 Get Order Details
- **Description**: Retrieve detailed information of a specific order
- **Input**: Order ID
- **Output**: Order details (including order items list)
- **Validation**: Can only view own orders

#### 2.2.5 Update Order Status
- **Description**: Change order status
- **Input**:
  - Order ID
  - Status to change to
- **Output**: Updated order information
- **Status Transitions**:
  - PENDING → CONFIRMED
  - PENDING → CANCELLED
- **Validation**: Invalid status transitions not allowed

#### 2.2.6 Cancel Order
- **Description**: Cancel an order
- **Input**: Order ID
- **Output**: Cancelled order information
- **Processing Logic**:
  1. Change order status to CANCELLED
  2. Restore stock
- **Constraint**: Only PENDING orders can be cancelled

### 2.3 User Management (User Service)

#### 2.3.1 Sign Up
- **Description**: Register a new user
- **Input**:
  - Email (Required, email format)
  - Password (Required, minimum 8 chars)
  - Name (Required, max 50 chars)
  - Phone number (Optional)
- **Output**: Created user information (excluding password)
- **Validation**:
  - Email must be unique
  - Email format validation
  - Password stored encrypted

#### 2.3.2 Login
- **Description**: Perform user authentication
- **Input**:
  - Email
  - Password
- **Output**: Authentication token (JWT) or session ID
- **Validation**:
  - Verify email/password match
  - 401 error on login failure

#### 2.3.3 Get User Profile
- **Description**: Retrieve logged-in user's information
- **Input**: Authentication token
- **Output**: User information (excluding password)
- **Validation**: Valid authentication token required

#### 2.3.4 Update User Profile
- **Description**: Update user information
- **Input**:
  - Authentication token
  - Fields to update (name, phone number)
- **Output**: Updated user information
- **Constraint**: Email cannot be changed

#### 2.3.5 Change Password
- **Description**: Change user password
- **Input**:
  - Authentication token
  - Current password
  - New password
- **Output**: Change success message
- **Validation**:
  - Verify current password match
  - Validate new password format

## 3. Non-Functional Requirements

### 3.1 Performance
- API response time: Average under 200ms
- Concurrent users: Support 100+ users
- Database query optimization (prevent N+1 problem)

### 3.2 Security
- Password encryption (BCrypt)
- SQL Injection prevention
- XSS prevention
- HTTPS communication (production environment)
- Authentication/Authorization handling

### 3.3 Scalability
- Horizontally scalable architecture
- Stateless application design
- Database connection pool management

### 3.4 Availability
- Health check endpoint
- Graceful shutdown support
- Error handling and logging

### 3.5 Monitoring
- Application logs (INFO, ERROR levels)
- API call logs
- Error tracking

## 4. Data Model

### 4.1 Product
```
- id: Long (PK, Auto Increment)
- name: String (100 chars, NOT NULL, UNIQUE)
- description: String (1000 chars)
- price: BigDecimal (NOT NULL)
- stockQuantity: Integer (NOT NULL, >= 0)
- category: String (50 chars, NOT NULL)
- imageUrl: String (500 chars)
- deleted: Boolean (default: false)
- createdAt: LocalDateTime (NOT NULL)
- updatedAt: LocalDateTime (NOT NULL)
```

### 4.2 Order
```
- id: Long (PK, Auto Increment)
- userId: Long (FK, NOT NULL)
- status: Enum (PENDING, CONFIRMED, SHIPPED, DELIVERED, CANCELLED)
- totalAmount: BigDecimal (NOT NULL)
- createdAt: LocalDateTime (NOT NULL)
- updatedAt: LocalDateTime (NOT NULL)
```

### 4.3 OrderItem
```
- id: Long (PK, Auto Increment)
- orderId: Long (FK, NOT NULL)
- productId: Long (FK, NOT NULL)
- productName: String (100 chars, NOT NULL)
- price: BigDecimal (NOT NULL)
- quantity: Integer (NOT NULL, > 0)
```

### 4.4 User
```
- id: Long (PK, Auto Increment)
- email: String (100 chars, NOT NULL, UNIQUE)
- password: String (255 chars, NOT NULL, encrypted)
- name: String (50 chars, NOT NULL)
- phoneNumber: String (20 chars)
- createdAt: LocalDateTime (NOT NULL)
- updatedAt: LocalDateTime (NOT NULL)
```

## 5. API Endpoints

### 5.1 Product API
- `POST /api/products` - Create product
- `GET /api/products` - List products
- `GET /api/products/{id}` - Get product details
- `PUT /api/products/{id}` - Update product
- `DELETE /api/products/{id}` - Delete product

### 5.2 Order API
- `POST /api/orders` - Create order
- `GET /api/orders` - List orders
- `GET /api/orders/{id}` - Get order details
- `PATCH /api/orders/{id}/status` - Update order status
- `POST /api/orders/{id}/cancel` - Cancel order

### 5.3 User API
- `POST /api/users/signup` - Sign up
- `POST /api/users/login` - Login
- `GET /api/users/me` - Get my profile
- `PUT /api/users/me` - Update my profile
- `PUT /api/users/me/password` - Change password

### 5.4 Health Check
- `GET /actuator/health` - Application health check

## 6. Infrastructure Modernization Phases

### Phase 1: Legacy Monolithic (Current)
- Single Spring Boot application
- H2 in-memory database
- Single EC2 instance deployment
- Manual deployment

### Phase 2: Database Modernization
- H2 → MySQL migration
- EC2 MySQL → Amazon RDS for MySQL
- Connection pool optimization
- Automated backup/recovery

### Phase 3: Containerization
- Dockerfile creation
- Docker Compose local environment
- Amazon ECR image repository
- Amazon ECS (Fargate) deployment
- Application Load Balancer integration

### Phase 4: Microservices Decomposition
- Product Service separation
- Order Service separation
- User Service separation
- Inter-service REST API communication
- API Gateway or ALB routing

### Phase 5: AWS Managed Services Integration
- Image storage: Amazon S3
- Caching: Amazon ElastiCache (Redis)
- Async processing: Amazon SQS/SNS
- Logging: CloudWatch Logs
- Monitoring: CloudWatch + X-Ray
- Secret management: AWS Secrets Manager

## 7. Development Priorities

### Sprint 1: Basic Features
1. Data model and entity creation
2. Product CRUD API
3. User signup/login
4. Basic exception handling

### Sprint 2: Order Features
1. Order creation API
2. Stock management logic
3. Order retrieval API
4. Transaction handling

### Sprint 3: Quality Enhancement
1. Pagination and sorting
2. Enhanced validation logic
3. Improved error handling
4. Logging addition

### Sprint 4: Infrastructure Preparation
1. Dockerfile creation
2. Docker Compose setup
3. Health check endpoint
4. Environment variable configuration

## 8. Constraints and Assumptions

### 8.1 Constraints
- Payment functionality not implemented (only order creation)
- Shipping tracking not implemented
- Admin features minimized
- Image upload stores URL only (actual file upload in Phase 5)

### 8.2 Assumptions
- All prices in KRW (Korean Won)
- No tax calculation
- Free shipping
- Stock is simple integer count
- Basic concurrency control (optimistic locking)
