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
  # int_alb_from_app(standalone) 규칙과 공존 — 인라인 재조정으로 지워지지 않게.
  lifecycle {
    ignore_changes = [ingress]
  }
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-pri-sg-int-alb" })
}

# 백엔드 → ALB2 :80 허용 (토큰 validate/complete 를 큐로 호출).
# ALB1 은 internet-facing 이라 백엔드에서 도달 불가 → 내부 ALB2 경유로 큐 호출.
resource "aws_vpc_security_group_ingress_rule" "int_alb_from_app" {
  security_group_id            = aws_security_group.int_alb.id
  description                  = "HTTP 80 from backend (queue validate/complete via ALB2)"
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = aws_security_group.app.id
}

# ALB2 → 큐 :8081 허용 (위 /api/queue 규칙 포워딩 대상).
resource "aws_vpc_security_group_ingress_rule" "queue_from_int_alb" {
  security_group_id            = aws_security_group.queue.id
  description                  = "HTTP 8081 from internal ALB2 (backend queue calls)"
  ip_protocol                  = "tcp"
  from_port                    = 8081
  to_port                      = 8081
  referenced_security_group_id = aws_security_group.int_alb.id
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

# ALB2 전용 큐 TG — 하나의 TG 는 LB 하나에만 연결 가능해서 ALB1 의 queue TG 재사용 불가.
# 큐 ASG 가 이 TG 에도 등록됨(queue.tf target_group_arns).
resource "aws_lb_target_group" "queue_internal" {
  name        = "${local.name_prefix}-pri-queue-int-tg"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/actuator/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
    healthy_threshold   = var.alb_health_check_healthy_threshold
    unhealthy_threshold = var.alb_health_check_unhealthy_threshold
    interval            = var.alb_health_check_interval_seconds
    timeout             = var.alb_health_check_timeout_seconds
  }
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-pri-queue-int-tg" })
}

# 백엔드 → ALB2 /api/queue/* → 큐 TG (토큰 validate/complete).
# 그 외(default) 는 백엔드 TG — 큐 프록시가 포워딩해온 /api/** 처리.
resource "aws_lb_listener_rule" "internal_queue" {
  listener_arn = aws_lb_listener.internal_http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.queue_internal.arn
  }
  condition {
    path_pattern { values = ["/api/queue/*"] }
  }
}
