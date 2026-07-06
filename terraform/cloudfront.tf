# =============================================================================
# cloudfront.tf — CDN (Public ALB 앞단)
#   Internet ─HTTPS─▶ CloudFront ─HTTP─▶ Public ALB ─▶ Frontend ASG
# 캐시 전략:
#   /assets/*  : Vite 해시 불변 자산 → 엣지 캐싱 (CachingOptimized)
#   그 외(default: index.html, /api, /actuator) : 캐시 안 함 + 쿠키/헤더 전달
#     → SPA HTML 항상 최신, 세션 쿠키(SESSION) 정상 왕복.
# 뷰어는 CloudFront 기본 인증서로 HTTPS 종료 (커스텀 도메인/ACM 미사용).
# =============================================================================

# ---------- AWS 관리형 정책 (ID 하드코딩 대신 이름으로 lookup) ----------
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewer"
}

resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${local.name_prefix} e-commerce CDN"
  default_root_object = "index.html"
  price_class         = var.cloudfront_price_class

  origin {
    domain_name = aws_lb.web.dns_name
    origin_id   = "${local.name_prefix}-web-alb"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # ALB 는 HTTP 80 리스너만 운영
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # 기본: index.html + /api + /actuator — 캐시 없이 쿠키/헤더/쿼리 전달
  default_cache_behavior {
    target_origin_id         = "${local.name_prefix}-web-alb"
    viewer_protocol_policy   = "redirect-to-https"
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD"]
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
    compress                 = true
  }

  # 정적 해시 자산 — 엣지 캐싱
  ordered_cache_behavior {
    path_pattern           = "/assets/*"
    target_origin_id       = "${local.name_prefix}-web-alb"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true # *.cloudfront.net 기본 인증서 (커스텀 도메인 시 ACM 로 교체)
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-cdn" })
}
