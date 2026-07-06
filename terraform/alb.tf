# =============================================================================
# alb.tf — API ALB (internet-facing, CloudFront 오리진)
#   CloudFront ─HTTP 80─▶ API ALB ─8080─▶ Backend ASG (Spring)
# ALB 는 public subnet, SG 로 CloudFront IP 만 허용. 백엔드는 private app subnet.
# =============================================================================

resource "aws_lb" "api" {
  name                       = "${local.name_prefix}-pub-api-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.api_alb.id]
  subnets                    = [for s in aws_subnet.public : s.id]
  idle_timeout               = var.alb_idle_timeout_seconds
  drop_invalid_header_fields = true
  tags                       = merge(local.common_tags, { Name = "${local.name_prefix}-pub-api-alb" })
}

resource "aws_lb_target_group" "api" {
  name        = "${local.name_prefix}-pub-api-tg"
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

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-pub-api-tg" })
}

resource "aws_lb_listener" "api_http" {
  load_balancer_arn = aws_lb.api.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}
