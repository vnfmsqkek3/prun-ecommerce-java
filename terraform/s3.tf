# =============================================================================
# s3.tf — 버킷 2종
#   artifacts : seed(backend/queue jar) + CodePipeline 저장소
#   static    : 프론트 SPA 정적 (CloudFront 기본 오리진, OAC)
# static 은 퍼블릭 차단 + CloudFront OAC 로만 접근.
# =============================================================================

# ---------- Artifacts ----------
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
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ---------- Static site (SPA) ----------
resource "aws_s3_bucket" "static" {
  bucket_prefix = "${local.name_prefix}-static-"
  force_destroy = true
  tags          = merge(local.common_tags, { Name = "${local.name_prefix}-static" })
}

resource "aws_s3_bucket_public_access_block" "static" {
  bucket                  = aws_s3_bucket.static.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "static" {
  bucket = aws_s3_bucket.static.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ---------- Bucket policy: CloudFront OAC 만 GetObject 허용 ----------
data "aws_iam_policy_document" "static_oac" {
  statement {
    sid       = "AllowCloudFrontOAC"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.main.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "static" {
  bucket = aws_s3_bucket.static.id
  policy = data.aws_iam_policy_document.static_oac.json
}
