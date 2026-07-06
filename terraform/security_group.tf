# =============================================================================
# security_group.tf — SG chain (최소권한, 인접 tier 만 허용)
#   CloudFront → api-alb(80) → app(8080) → rds(3306)/redis(6379)
#   EICE → app (22)
# (정적은 S3+CloudFront 서빙 → web tier SG 없음)
# =============================================================================

# CloudFront edge 노드 IP 대역 (관리형 prefix list) — ALB 를 CloudFront 경유로만 노출.
data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

# ---------- API ALB (internet-facing) — CloudFront 에서만 HTTP 80 ----------
resource "aws_security_group" "api_alb" {
  name        = "${local.name_prefix}-pub-sg-api-alb"
  description = "API ALB - HTTP 80 from CloudFront edge only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP 80 from CloudFront edge only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  }
  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-pub-sg-api-alb" })
}

# ---------- Backend ASG (app) — API ALB → 8080, EICE → 22 ----------
resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-pri-sg-app"
  description = "Backend Spring - 8080 from API ALB, SSH from EICE"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP 8080 from API ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.api_alb.id]
  }
  ingress {
    description     = "SSH from EC2 Instance Connect Endpoint"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.eice.id]
  }
  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-pri-sg-app" })
}

# ---------- EC2 Instance Connect Endpoint — private 인스턴스 SSH ----------
resource "aws_security_group" "eice" {
  name        = "${local.name_prefix}-pri-sg-eice"
  description = "EC2 Instance Connect Endpoint - egress SSH to private instances"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "SSH to instances in VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-pri-sg-eice" })
}

# ---------- RDS MySQL — App → 3306 ----------
resource "aws_security_group" "db" {
  name        = "${local.name_prefix}-pri-sg-rds"
  description = "RDS MySQL 3306 from App SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from backend"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-pri-sg-rds" })
}

# ---------- ElastiCache Redis — App → 6379 ----------
resource "aws_security_group" "cache" {
  name        = "${local.name_prefix}-pri-sg-redis"
  description = "ElastiCache Redis 6379 from App SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Redis from backend"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-pri-sg-redis" })
}
