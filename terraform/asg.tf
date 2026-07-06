# =============================================================================
# asg.tf — Backend Launch Template + ASG + target-tracking scaling (app tier)
# AL2023 인스턴스가 부팅 시 Corretto17 + systemd 로 app.jar 를 네이티브 구동.
# CodeDeploy 에이전트 탑재 → 이후 배포는 CodePipeline/CodeDeploy.
# (프론트는 S3+CloudFront → web ASG 없음)
# =============================================================================

locals {
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
    media_bucket      = aws_s3_bucket.media.bucket
  }))
}

resource "aws_launch_template" "app" {
  name_prefix   = "${local.name_prefix}-pri-lt-app-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.app_instance_type
  # keyless — 접속은 EC2 Instance Connect Endpoint(ec2.tf)로. key pair 쓰려면 var 설정.
  key_name = var.ssh_key_name != "" ? var.ssh_key_name : null

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
  target_group_arns         = [aws_lb_target_group.api.arn]
  health_check_type         = "ELB"
  health_check_grace_period = var.asg_health_check_grace_seconds
  # 인프라 먼저 apply — seed jar/CodeDeploy 배포 전이라 헬스 대기하지 않음(안 그러면 apply 타임아웃).
  wait_for_capacity_timeout = "0"

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

  # 백엔드는 부팅 시 RDS/Redis/SSM/S3 를 호출하므로 준비 완료 후 launch.
  depends_on = [
    aws_db_instance.main,
    aws_elasticache_replication_group.session,
    aws_lb_listener.api_http,
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
