# =============================================================================
# outputs.tf — furn e-commerce
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

output "api_alb_dns_name" {
  description = "API ALB DNS (CloudFront /api 오리진)"
  value       = aws_lb.api.dns_name
}

output "static_bucket" {
  description = "프론트 정적 SPA S3 버킷"
  value       = aws_s3_bucket.static.bucket
}

output "media_bucket" {
  description = "미디어(업로드 이미지) S3 버킷"
  value       = aws_s3_bucket.media.bucket
}

output "artifact_bucket" {
  description = "아티팩트 버킷 (백엔드 seed + 파이프라인 저장소)"
  value       = aws_s3_bucket.artifacts.bucket
}

output "initial_deploy_commands" {
  description = "최초 배포 (파이프라인 없이 바로 올리기)"
  value = {
    backend_seed = "aws s3 cp backend/build/libs/*.jar s3://${aws_s3_bucket.artifacts.bucket}/${local.backend_seed_key}"
    queue_seed   = "aws s3 cp queue-server/build/libs/*.jar s3://${aws_s3_bucket.artifacts.bucket}/${local.queue_seed_key}"
    frontend_static = join(" && ", [
      "cd frontend && npm ci && npm run build",
      "printf 'window.ENV={API_BASE_URL:\"\",STATIC_ASSETS_URL:\"\"};' > dist/env-config.js",
      "aws s3 sync dist/ s3://${aws_s3_bucket.static.bucket}/ --delete",
      "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.main.id} --paths '/*'",
    ])
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
    queue    = aws_codepipeline.queue.name
  }
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
