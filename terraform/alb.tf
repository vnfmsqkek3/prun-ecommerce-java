# =============================================================================
# alb.tf — Public ALB(web) + Internal ALB(back)
#   Public ALB : Internet → Frontend ASG (nginx :8080), health /health
#   Internal ALB : Frontend nginx → Backend ASG (Spring :8080), health /actuator/health
# baseline: ACM 수동 적용 전까지 HTTP 리스너만 운영.
# =============================================================================

# ---------- Public ALB (web tier) ----------
resource "aws_lb" "web" {
  name                       = "${local.name_prefix}-pub-web-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.web_alb.id]
  subnets                    = [for s in aws_subnet.public : s.id]
  idle_timeout               = var.alb_idle_timeout_seconds
  drop_invalid_header_fields = true
  tags                       = merge(local.common_tags, { Name = "${local.name_prefix}-pub-web-alb" })
}

resource "aws_lb_target_group" "web" {
  name        = "${local.name_prefix}-pub-web-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = var.web_health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
    healthy_threshold   = var.alb_health_check_healthy_threshold
    unhealthy_threshold = var.alb_health_check_unhealthy_threshold
    interval            = var.alb_health_check_interval_seconds
    timeout             = var.alb_health_check_timeout_seconds
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-pub-web-tg" })
}

resource "aws_lb_listener" "web_http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# ---------- Internal ALB (app tier) ----------
resource "aws_lb" "back" {
  name               = "${local.name_prefix}-pri-back-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.back_alb.id]
  subnets            = [for s in aws_subnet.private_app : s.id]
  idle_timeout       = var.alb_idle_timeout_seconds
  tags               = merge(local.common_tags, { Name = "${local.name_prefix}-pri-back-alb" })
}

resource "aws_lb_target_group" "back" {
  name        = "${local.name_prefix}-pri-back-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = var.back_health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
    healthy_threshold   = var.alb_health_check_healthy_threshold
    unhealthy_threshold = var.alb_health_check_unhealthy_threshold
    interval            = var.alb_health_check_interval_seconds
    timeout             = var.alb_health_check_timeout_seconds
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-pri-back-tg" })
}

resource "aws_lb_listener" "back_http" {
  load_balancer_arn = aws_lb.back.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.back.arn
  }
}
