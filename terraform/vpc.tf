# =============================================================================
# vpc.tf — Network layer
# 모든 서브넷에 명시적 route table 연결. NAT Gateway 는 public subnet 에만 배치.
# 서브넷 4 tier × 2 AZ = 8 subnets, RT: public 1 + app AZ별 2 + cache/db 각 1 = 5
#   public : API ALB(internet-facing, CloudFront-locked), NAT GW, EICE
#   app    : Backend ASG (Spring)
#   cache  : ElastiCache Redis
#   db     : RDS MySQL
# (프론트 정적은 S3+CloudFront 서빙 → 별도 EC2 web tier 없음)
# CIDR: 10.100.0.0/20 → /24 (256 IP/subnet, AWS 예약 5개 제외 251 usable). idx 0~7 사용.
# =============================================================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-pub-igw"
  })
}

# ---------- Subnets (newbits=4 → /24) ----------
# Public — idx 0,1
resource "aws_subnet" "public" {
  for_each                = { for idx, az in local.azs : az => idx }
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, each.value)
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-pub-sbn-${local.az_suffix[each.key]}"
    Tier = "public"
  })
}

# Private app (Backend ASG) — idx 2,3
resource "aws_subnet" "private_app" {
  for_each          = { for idx, az in local.azs : az => idx }
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, each.value + 2)
  availability_zone = each.key
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-pri-sbn-app-${local.az_suffix[each.key]}"
    Tier = "app"
  })
}

# Private cache (Redis) — idx 4,5
resource "aws_subnet" "private_cache" {
  for_each          = { for idx, az in local.azs : az => idx }
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, each.value + 4)
  availability_zone = each.key
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-pri-sbn-cache-${local.az_suffix[each.key]}"
    Tier = "cache"
  })
}

# Private db (RDS) — idx 6,7
resource "aws_subnet" "private_db" {
  for_each          = { for idx, az in local.azs : az => idx }
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, each.value + 6)
  availability_zone = each.key
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-pri-sbn-db-${local.az_suffix[each.key]}"
    Tier = "db"
  })
}

# ---------- NAT Gateway (AZ 이중화) ----------
resource "aws_eip" "nat" {
  for_each   = toset(local.azs)
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-pub-eip-nat-${local.az_suffix[each.key]}"
  })
}

resource "aws_nat_gateway" "main" {
  for_each      = aws_subnet.public
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id
  depends_on    = [aws_internet_gateway.main]
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-pub-nat-${local.az_suffix[each.key]}"
  })
}

# ---------- Route Tables ----------
# Public — IGW 0/0
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-pub-rtb"
  })
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private app — AZ별 RT (자기 AZ NAT 로 0/0 → SSM/CodeDeploy/dnf outbound. AZ 장애 격리).
resource "aws_route_table" "private_app" {
  for_each = aws_subnet.private_app
  vpc_id   = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[each.key].id
  }
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-pri-rtb-app-${local.az_suffix[each.key]}"
  })
}

resource "aws_route_table_association" "private_app" {
  for_each       = aws_subnet.private_app
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_app[each.key].id
}

# Private cache — 0/0 없음 (관리형 서비스, outbound 불필요)
resource "aws_route_table" "private_cache" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-pri-rtb-cache"
  })
}

resource "aws_route_table_association" "private_cache" {
  for_each       = aws_subnet.private_cache
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_cache.id
}

# Private db — 0/0 없음 (DB tier 완전 격리)
resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-pri-rtb-db"
  })
}

resource "aws_route_table_association" "private_db" {
  for_each       = aws_subnet.private_db
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_db.id
}

# ---------- S3 Gateway VPC Endpoint ----------
# 백엔드의 S3 트래픽(아티팩트 pull, 미디어 업로드, CodeDeploy 번들)이 NAT 가 아닌
# 이 endpoint 로 직행. app RT 에 endpoint 라우트 주입 (미디어 IAM 도 이 endpoint 강제).
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [for rt in aws_route_table.private_app : rt.id]
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-pri-vpce-s3"
  })
}
