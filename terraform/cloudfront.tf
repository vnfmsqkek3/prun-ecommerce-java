# =============================================================================
# cloudfront.tf — 단일 CloudFront 에서 경로 분기
#   default        → S3 static (SPA)           [OAC]
#   /api/*         → API ALB   (동적)           [캐시 없음 + 쿠키/헤더 전달]
#   /actuator/*    → API ALB   (헬스)
# 뷰어는 CloudFront 기본 인증서로 HTTPS 종료. SPA 딥링크는 403/404 → index.html.
# =============================================================================

# ---------- AWS 관리형 정책 ----------
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewer"
}

# ---------- OAC (S3 오리진 서명 접근) ----------
resource "aws_cloudfront_origin_access_control" "s3" {
  name                              = "${local.name_prefix}-s3-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${local.name_prefix} e-commerce CDN"
  default_root_object = "index.html"
  price_class         = var.cloudfront_price_class

  # 오리진 1 — 정적 SPA (S3)
  origin {
    domain_name              = aws_s3_bucket.static.bucket_regional_domain_name
    origin_id                = "static-s3"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
  }

  # 오리진 2 — API (ALB)
  origin {
    domain_name = aws_lb.api.dns_name
    origin_id   = "api-alb"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # 기본 — 정적 SPA
  default_cache_behavior {
    target_origin_id       = "static-s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
    compress               = true
  }

  # /api/* — 동적 (캐시 없음 + 쿠키/헤더 전달)
  ordered_cache_behavior {
    path_pattern             = "/api/*"
    target_origin_id         = "api-alb"
    viewer_protocol_policy   = "redirect-to-https"
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD"]
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
    compress                 = true
  }

  # /actuator/* — 헬스
  ordered_cache_behavior {
    path_pattern             = "/actuator/*"
    target_origin_id         = "api-alb"
    viewer_protocol_policy   = "redirect-to-https"
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD"]
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
  }

  # SPA 딥링크: S3 가 없는 키에 403/404 → index.html 200
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }
  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true # 커스텀 도메인 시 ACM 로 교체
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-cdn" })
}
