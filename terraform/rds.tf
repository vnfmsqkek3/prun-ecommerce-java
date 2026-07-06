# =============================================================================
# rds.tf — RDS MySQL Multi-AZ (private db subnet)
# password 는 ssm.tf 의 random_password 를 사용 (SecureString 으로도 저장).
# 암호화는 AWS 관리형 키(aws/rds). 별도 CMK 미사용 (데모 단순화).
# =============================================================================

resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-pri-rds-subnet-group"
  subnet_ids = [for s in aws_subnet.private_db : s.id]
  tags       = merge(local.common_tags, { Name = "${local.name_prefix}-pri-rds-subnet-group" })
}

resource "aws_db_parameter_group" "main" {
  name   = "${local.name_prefix}-pri-rds-params"
  family = var.db_parameter_group_family
  # 앱이 utf8mb4 를 요구 (application.properties)
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-pri-rds-params" })
}

resource "aws_db_instance" "main" {
  identifier        = "${local.name_prefix}-pri-rds"
  engine            = "mysql"
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage_gb
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_master_username
  password = random_password.db.result

  multi_az               = var.db_multi_az
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  parameter_group_name   = aws_db_parameter_group.main.name

  backup_retention_period = 7
  backup_window           = "16:00-16:30"         # UTC
  maintenance_window      = "sun:18:00-sun:19:00" # UTC
  copy_tags_to_snapshot   = true

  deletion_protection       = var.db_deletion_protection
  skip_final_snapshot       = var.db_skip_final_snapshot
  final_snapshot_identifier = var.db_skip_final_snapshot ? null : "${local.name_prefix}-pri-rds-final-snapshot"

  enabled_cloudwatch_logs_exports = ["error", "slowquery"]

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-pri-rds" })
}
