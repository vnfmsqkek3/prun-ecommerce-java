# =============================================================================
# ssm.tf — SSM Parameter Store
# DB master password 만 SecureString 으로 관리 (backend user-data 가 부팅 시 fetch).
# endpoint(호스트/포트/DB명) 등 비밀 아닌 값은 user-data 에 templatefile 로 직접 주입.
# =============================================================================

resource "random_password" "db" {
  length  = 24
  special = false # MySQL URL/셸 이스케이프 이슈 회피
}

resource "aws_ssm_parameter" "db_password" {
  name        = "${local.ssm_prefix}/db/password"
  description = "RDS master password (furn backend DB_PASSWORD)"
  type        = "SecureString"
  value       = random_password.db.result
  tags        = merge(local.common_tags, { Name = "${local.name_prefix}-ssm-db-password" })
}
