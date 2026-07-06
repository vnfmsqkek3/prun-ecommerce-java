# Database Initialization Scripts

이 디렉토리에는 운영 환경(MySQL/RDS) 데이터베이스 초기화를 위한 SQL 스크립트가 포함되어 있습니다.

## 파일 설명

### schema.sql
데이터베이스 스키마 생성 스크립트입니다.

**포함 내용:**
- 6개 테이블 생성 (users, products, orders, order_items, carts, cart_items)
- 인덱스 설정
- 외래키 제약조건
- 적절한 데이터 타입 및 제약조건

**실행 방법:**
```bash
mysql -u username -p database_name < schema.sql
```

### data.sql
샘플 데이터 삽입 스크립트입니다.

**포함 내용:**
- 샘플 사용자 2명 (admin, user)
- 샘플 상품 10개 (각 카테고리별)

**실행 방법:**
```bash
mysql -u username -p database_name < data.sql
```

## 사용 시나리오

### 1. 개발 환경 (Dev) 초기 설정
```bash
# MySQL 데이터베이스 생성
mysql -u root -p
CREATE DATABASE ecommerce_dev CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'dev_user'@'localhost' IDENTIFIED BY 'dev_password';
GRANT ALL PRIVILEGES ON ecommerce_dev.* TO 'dev_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# 스키마 생성
mysql -u dev_user -p ecommerce_dev < schema.sql

# 샘플 데이터 삽입 (선택사항)
mysql -u dev_user -p ecommerce_dev < data.sql
```

### 2. 운영 환경 (Prod) 초기 설정
```bash
# RDS MySQL 접속
mysql -h your-rds-endpoint.rds.amazonaws.com -u prod_user -p

# 데이터베이스 생성
CREATE DATABASE ecommerce_prod CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ecommerce_prod;

# 스키마 생성
SOURCE schema.sql;

# 운영 환경에서는 샘플 데이터 삽입하지 않음
```

## 주의사항

1. **운영 환경에서는 data.sql을 실행하지 마세요**
   - 샘플 데이터는 개발/테스트 용도입니다

2. **스키마 변경 시**
   - Entity 변경 후 schema.sql도 함께 업데이트해야 합니다
   - 운영 환경에서는 마이그레이션 스크립트를 별도로 관리하세요

3. **비밀번호 보안**
   - 샘플 데이터의 비밀번호는 평문입니다
   - 실제 운영에서는 암호화된 비밀번호를 사용하세요

4. **백업**
   - 운영 DB에 스크립트 실행 전 반드시 백업하세요
