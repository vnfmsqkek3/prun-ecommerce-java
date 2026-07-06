# =============================================================================
# asg.tf — Launch Template + ASG + target-tracking scaling (web / app)
# AL2023 인스턴스가 부팅 시 코드를 네이티브로 구동 (Docker 미사용):
#   web  : nginx + S3 시드 dist. /api,/actuator 를 internal ALB 로 프록시.
#   app  : Corretto17 + S3 시드 app.jar 를 systemd 서비스로 구동.
# 두 티어 모두 CodeDeploy 에이전트 탑재 → 이후 배포는 CodePipeline/CodeDeploy.
# LT 변경 시 rolling instance refresh (무중단 교체).
# =============================================================================

locals {
  web_user_data = base64encode(templatefile("${path.module}/userdata/frontend.sh.tftpl", {
    aws_region      = var.aws_region
    artifact_bucket = aws_s3_bucket.artifacts.bucket
    seed_key        = local.frontend_seed_key
    backend_url     = "http://${aws_lb.back.dns_name}"
  }))

  app_user_data = base64encode(templatefile("${path.module}/userdata/backend.sh.tftpl", {
    aws_region        = var.aws_region
    artifact_bucket   = aws_s3_bucket.artifacts.bucket
    seed_key          = local.backend_seed_key
    db_host           = aws_db_instance.main.address
    db_port           = aws_db_instance.main.port
    db_name           = var.db_name
    db_username       = var.db_master_username
    db_password_param = aws_ssm_parameter.db_password.name
    redis_host        = aws_elasticache_replication_group.session.primary_endpoint_address
    redis_port        = 6379
  }))
}

# ---------- Frontend (web) ----------
resource "aws_launch_template" "web" {
  name_prefix   = "${local.name_prefix}-pri-lt-web-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.web_instance_type
  key_name      = var.ssh_key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.web.name
  }

  vpc_security_group_ids = [aws_security_group.web.id]
  user_data              = local.web_user_data

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_type           = "gp3"
      volume_size           = var.web_root_volume_size_gb
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
    tags          = merge(local.common_tags, { Name = "${local.name_prefix}-pri-ec2-web" })
  }
  tag_specifications {
    resource_type = "volume"
    tags          = merge(local.common_tags, { Name = "${local.name_prefix}-pri-ebs-web" })
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-pri-lt-web" })
}

resource "aws_autoscaling_group" "web" {
  name                      = "${local.name_prefix}-pri-asg-web"
  min_size                  = var.web_asg_min_size
  max_size                  = var.web_asg_max_size
  desired_capacity          = var.web_asg_desired_capacity
  vpc_zone_identifier       = [for s in aws_subnet.private_web : s.id]
  target_group_arns         = [aws_lb_target_group.web.arn]
  health_check_type         = "ELB"
  health_check_grace_period = var.asg_health_check_grace_seconds

  launch_template {
    id      = aws_launch_template.web.id
    version = aws_launch_template.web.latest_version
  }

  dynamic "tag" {
    for_each = merge(local.common_tags, { Name = "${local.name_prefix}-pri-asg-web" })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  # BACKEND_URL 이 살아있는 internal ALB 를 가리키도록 백엔드 ALB 리스너 이후 launch.
  depends_on = [aws_lb_listener.back_http]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 300
    }
    triggers = ["launch_template"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "web_cpu_target" {
  name                   = "${local.name_prefix}-pri-asg-web-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.web.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.web_asg_target_cpu_utilization
  }
}

# ---------- Backend (app) ----------
resource "aws_launch_template" "app" {
  name_prefix   = "${local.name_prefix}-pri-lt-app-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.app_instance_type
  key_name      = var.ssh_key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }

  vpc_security_group_ids = [aws_security_group.app.id]
  user_data              = local.app_user_data

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_type           = "gp3"
      volume_size           = var.app_root_volume_size_gb
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
    tags          = merge(local.common_tags, { Name = "${local.name_prefix}-pri-ec2-app" })
  }
  tag_specifications {
    resource_type = "volume"
    tags          = merge(local.common_tags, { Name = "${local.name_prefix}-pri-ebs-app" })
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-pri-lt-app" })
}

resource "aws_autoscaling_group" "app" {
  name                      = "${local.name_prefix}-pri-asg-app"
  min_size                  = var.app_asg_min_size
  max_size                  = var.app_asg_max_size
  desired_capacity          = var.app_asg_desired_capacity
  vpc_zone_identifier       = [for s in aws_subnet.private_app : s.id]
  target_group_arns         = [aws_lb_target_group.back.arn]
  health_check_type         = "ELB"
  health_check_grace_period = var.asg_health_check_grace_seconds

  launch_template {
    id      = aws_launch_template.app.id
    version = aws_launch_template.app.latest_version
  }

  dynamic "tag" {
    for_each = merge(local.common_tags, { Name = "${local.name_prefix}-pri-asg-app" })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  # 백엔드는 부팅 시 RDS/Redis/SSM 를 호출하므로 준비 완료 후 launch.
  depends_on = [
    aws_db_instance.main,
    aws_elasticache_replication_group.session,
    aws_lb_listener.back_http,
    aws_ssm_parameter.db_password,
    aws_vpc_endpoint.s3,
  ]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 300
    }
    triggers = ["launch_template"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "app_cpu_target" {
  name                   = "${local.name_prefix}-pri-asg-app-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.app_asg_target_cpu_utilization
  }
}
