# =============================================================================
# s3.tf — 아티팩트 버킷
#   - seed/ : 최초 부팅 시 EC2 user-data 가 받는 코드 (초기 직접 배포)
#   - CodePipeline source/build 아티팩트 저장소 (이후 배포)
# =============================================================================

resource "aws_s3_bucket" "artifacts" {
  bucket_prefix = "${local.name_prefix}-artifacts-"
  force_destroy = true
  tags          = merge(local.common_tags, { Name = "${local.name_prefix}-artifacts" })
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled" # 롤백/이전 버전 참조
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # SSE-S3 (KMS 불필요 → 인스턴스/파이프라인 권한 단순)
    }
  }
}
