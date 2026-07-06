# =============================================================================
# outputs.tf — furn e-commerce 3-tier
# =============================================================================

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "site_url" {
  description = "사이트 진입점 (CloudFront HTTPS)"
  value       = "https://${aws_cloudfront_distribution.main.domain_name}"
}

output "cloudfront_domain_name" {
  description = "CloudFront 배포 도메인"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "web_alb_dns_name" {
  description = "Public ALB DNS (frontend 진입점)"
  value       = aws_lb.web.dns_name
}

output "back_alb_dns_name" {
  description = "Internal ALB DNS (frontend nginx → backend)"
  value       = aws_lb.back.dns_name
}

output "artifact_bucket" {
  description = "S3 아티팩트 버킷 (초기 시드 업로드 + 파이프라인 저장소)"
  value       = aws_s3_bucket.artifacts.bucket
}

output "seed_upload_commands" {
  description = "최초 배포용 시드 업로드 (빌드 후 실행)"
  value = {
    backend  = "aws s3 cp backend/build/libs/*.jar s3://${aws_s3_bucket.artifacts.bucket}/${local.backend_seed_key}"
    frontend = "cd frontend && tar czf /tmp/dist.tar.gz -C dist . && aws s3 cp /tmp/dist.tar.gz s3://${aws_s3_bucket.artifacts.bucket}/${local.frontend_seed_key}"
  }
}

output "github_connection_arn" {
  description = "CodeStar GitHub 연결 ARN — 콘솔에서 최초 1회 'Available' 로 승인 필요"
  value       = aws_codestarconnections_connection.github.arn
}

output "pipeline_names" {
  description = "CodePipeline 이름 (frontend / backend)"
  value = {
    frontend = aws_codepipeline.frontend.name
    backend  = aws_codepipeline.backend.name
  }
}

output "web_asg_name" {
  description = "Frontend Auto Scaling Group name"
  value       = aws_autoscaling_group.web.name
}

output "app_asg_name" {
  description = "Backend Auto Scaling Group name"
  value       = aws_autoscaling_group.app.name
}

output "rds_endpoint" {
  description = "RDS writer endpoint"
  value       = aws_db_instance.main.address
  sensitive   = true
}

output "redis_primary_endpoint" {
  description = "ElastiCache Redis primary endpoint (Spring Session REDIS_HOST)"
  value       = aws_elasticache_replication_group.session.primary_endpoint_address
  sensitive   = true
}

output "db_password_ssm_parameter" {
  description = "DB password 가 저장된 SSM SecureString parameter 이름"
  value       = aws_ssm_parameter.db_password.name
}
