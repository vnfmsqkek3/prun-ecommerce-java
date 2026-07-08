# =============================================================================
# alb_internal.tf — 내부 ALB2 (대기열 서버 → 백엔드 API)
#   CloudFront → ALB1(public) → 대기열(:8081, 프록시) → ALB2(internal,:80) → 백엔드(:8080)
# private_app subnet 에만 노출. SG 로 대기열 서버에서만 HTTP 80 허용.
# 백엔드 TG(aws_lb_target_group.api)는 이제 ALB1 이 아니라 이 ALB2 리스너에 연결.
# =============================================================================

resource "aws_security_group" "int_alb" {
  name        = "${local.name_prefix}-pri-sg-int-alb"
  description = "Internal ALB - HTTP 80 from queue server only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP 80 from queue server"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.queue.id]
  }
  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-pri-sg-int-alb" })
}

resource "aws_lb" "internal" {
  name                       = "${local.name_prefix}-pri-int-alb"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.int_alb.id]
  subnets                    = [for s in aws_subnet.private_app : s.id]
  idle_timeout               = var.alb_idle_timeout_seconds
  drop_invalid_header_fields = true
  tags                       = merge(local.common_tags, { Name = "${local.name_prefix}-pri-int-alb" })
}

# 백엔드 TG(:8080)는 alb.tf 에 정의됨(aws_lb_target_group.api). 여기서 ALB2 리스너에 연결.
resource "aws_lb_listener" "internal_http" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}
