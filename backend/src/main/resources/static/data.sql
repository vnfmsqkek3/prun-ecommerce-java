-- E-Commerce Demo Application
-- Sample Data Initialization Script
-- Target: MySQL 8.0+

-- Insert Sample Users
INSERT INTO users (email, password, name, phone_number, created_at, updated_at) VALUES
('admin@example.com', 'password123', '관리자', '010-1234-5678', NOW(), NOW()),
('user@example.com', 'userpass123', '홍길동', '010-9876-5432', NOW(), NOW());

-- Insert Sample Products
INSERT INTO products (name, description, price, stock_quantity, category, image_url, deleted, created_at, updated_at) VALUES
('노트북', '고성능 게이밍 노트북', 1800000.00, 10, 'ELECTRONICS', 'https://example.com/laptop.jpg', FALSE, NOW(), NOW()),
('마우스', '무선 게이밍 마우스', 30000.00, 50, 'ELECTRONICS', 'https://example.com/mouse.jpg', FALSE, NOW(), NOW()),
('키보드', '기계식 키보드', 120000.00, 30, 'ELECTRONICS', 'https://example.com/keyboard.jpg', FALSE, NOW(), NOW()),
('티셔츠', '면 100% 티셔츠', 29000.00, 100, 'CLOTHING', 'https://example.com/tshirt.jpg', FALSE, NOW(), NOW()),
('청바지', '데님 청바지', 59000.00, 80, 'CLOTHING', 'https://example.com/jeans.jpg', FALSE, NOW(), NOW()),
('사과', '신선한 사과 1kg', 5000.00, 200, 'FOOD', 'https://example.com/apple.jpg', FALSE, NOW(), NOW()),
('우유', '신선한 우유 1L', 3000.00, 150, 'FOOD', 'https://example.com/milk.jpg', FALSE, NOW(), NOW()),
('소설책', '베스트셀러 소설', 15000.00, 50, 'BOOK', 'https://example.com/novel.jpg', FALSE, NOW(), NOW()),
('수건', '호텔 수건 세트', 25000.00, 60, 'HOME', 'https://example.com/towel.jpg', FALSE, NOW(), NOW()),
('베개', '메모리폼 베개', 35000.00, 40, 'HOME', 'https://example.com/pillow.jpg', FALSE, NOW(), NOW());
