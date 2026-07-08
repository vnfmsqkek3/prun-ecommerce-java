# =============================================================================
# queue.tf — 대기열 서버 티어 (별도 ASG) + API ALB 경로 라우팅
#   CloudFront/백엔드 → API ALB(:80)
#       /api/queue/* → queue TG(:8081, queue-server ASG)  [redis 프로파일 → ElastiCache]
#       그 외 /api/*  → backend TG(:8080)
#   backend → 같은 API ALB 로 /api/queue 호출(토큰 검증) → api_alb SG 에 app SG 허용
# =============================================================================

# ---------- SG: queue-server (API ALB → 8081, EICE → 22) ----------
resource "aws_security_group" "queue" {
  name        = "${local.name_prefix}-pri-sg-queue"
  description = "Queue server - 8081 from API ALB, SSH from EICE"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP 8081 from API ALB"
    from_port       = 8081
    to_port         = 8081
    protocol        = "tcp"
    security_groups = [aws_security_group.api_alb.id]
  }
  ingress {
    description     = "SSH from EICE"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.eice.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-pri-sg-queue" })
}

# backend → API ALB(:80) 로 /api/queue 호출 허용 (기존 SG 편집 없이 규칙만 추가)
resource "aws_vpc_security_group_ingress_rule" "api_alb_from_app" {
  security_group_id            = aws_security_group.api_alb.id
  description                  = "HTTP 80 from backend (queue calls via ALB)"
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = aws_security_group.app.id
}

# queue-server → ElastiCache Redis 6379 허용
resource "aws_vpc_security_group_ingress_rule" "cache_from_queue" {
  security_group_id            = aws_security_group.cache.id
  description                  = "Redis 6379 from queue server"
  ip_protocol                  = "tcp"
  from_port                    = 6379
  to_port                      = 6379
  referenced_security_group_id = aws_security_group.queue.id
}

# ---------- IAM: queue instance role (S3 아티팩트 read + SSM + CW) ----------
resource "aws_iam_role" "queue" {
  name               = "${local.name_prefix}-queue-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
  tags               = merge(local.common_tags, { Name = "${local.name_prefix}-queue-role" })
}

data "aws_iam_policy_document" "queue_artifacts" {
  statement {
    sid       = "ReadArtifacts"
    actions   = ["s3:GetObject", "s3:GetObjectVersion"]
    resources = ["${aws_s3_bucket.artifacts.arn}/*"]
  }
  statement {
    sid       = "ListArtifacts"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.artifacts.arn]
  }
}

resource "aws_iam_role_policy" "queue_artifacts" {
  name   = "${local.name_prefix}-queue-artifacts"
  role   = aws_iam_role.queue.id
  policy = data.aws_iam_policy_document.queue_artifacts.json
}

resource "aws_iam_role_policy_attachment" "queue_ssm" {
  role       = aws_iam_role.queue.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "queue_cw" {
  role       = aws_iam_role.queue.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "queue" {
  name = "${local.name_prefix}-queue-profile"
  role = aws_iam_role.queue.name
}

# ---------- Target Group + ALB 경로 규칙 ----------
resource "aws_lb_target_group" "queue" {
  name        = "${local.name_prefix}-pri-queue-tg"
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
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-pri-queue-tg" })
}

# ALB1 리스너 기본 동작이 이미 큐 TG 로 포워딩(alb.tf) — 경로 규칙 불필요.
# 큐 서버가 /api/queue 는 자체 처리, 그 외 /api/** 는 ALB2(백엔드)로 프록시.

# ---------- Launch Template + ASG ----------
locals {
  queue_user_data = base64encode(templatefile("${path.module}/userdata/queue.sh.tftpl", {
    aws_region      = var.aws_region
    artifact_bucket = aws_s3_bucket.artifacts.bucket
    seed_key        = local.queue_seed_key
    redis_host      = aws_elasticache_replication_group.session.primary_endpoint_address
    redis_port      = 6379
    queue_capacity  = var.queue_capacity
    backend_url     = "http://${aws_lb.internal.dns_name}" # 프록시 대상 — 내부 ALB2
  }))
}

resource "aws_launch_template" "queue" {
  name_prefix   = "${local.name_prefix}-pri-lt-queue-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.queue_instance_type
  key_name      = var.ssh_key_name != "" ? var.ssh_key_name : null

  iam_instance_profile { name = aws_iam_instance_profile.queue.name }
  vpc_security_group_ids = [aws_security_group.queue.id]
  user_data              = local.queue_user_data

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_type           = "gp3"
      volume_size           = 30
      encrypted             = true
      delete_on_termination = true
    }
  }
  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.common_tags, { Name = "${local.name_prefix}-pri-ec2-queue" })
  }
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-pri-lt-queue" })
}

resource "aws_autoscaling_group" "queue" {
  name                      = "${local.name_prefix}-pri-asg-queue"
  min_size                  = var.queue_asg_min_size
  max_size                  = var.queue_asg_max_size
  desired_capacity          = var.queue_asg_desired_capacity
  vpc_zone_identifier       = [for s in aws_subnet.private_app : s.id]
  target_group_arns         = [aws_lb_target_group.queue.arn]
  health_check_type         = "ELB"
  health_check_grace_period = var.asg_health_check_grace_seconds
  wait_for_capacity_timeout = "0"

  launch_template {
    id      = aws_launch_template.queue.id
    version = aws_launch_template.queue.latest_version
  }

  dynamic "tag" {
    for_each = merge(local.common_tags, { Name = "${local.name_prefix}-pri-asg-queue" })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  depends_on = [
    aws_elasticache_replication_group.session,
    aws_lb_listener.api_http,
    aws_vpc_endpoint.s3,
  ]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 180
    }
    triggers = ["launch_template"]
  }
  lifecycle { create_before_destroy = true }
}

resource "aws_autoscaling_policy" "queue_cpu_target" {
  name                   = "${local.name_prefix}-pri-asg-queue-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.queue.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification { predefined_metric_type = "ASGAverageCPUUtilization" }
    target_value = var.app_asg_target_cpu_utilization
  }
}
