# =============================================================================
# iam.tf — Backend EC2 Instance Role / Profile (최소 권한)
#   app : S3 아티팩트 read + 미디어 버킷 RW(S3 endpoint 강제) + DB password SSM
#         + SSM Session Manager + CloudWatch agent
# (프론트는 S3+CloudFront 서빙 → EC2 web 롤 없음. CI/CD 롤은 cicd.tf)
# =============================================================================

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app" {
  name               = "${local.name_prefix}-app-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
  tags               = merge(local.common_tags, { Name = "${local.name_prefix}-app-role" })
}

resource "aws_iam_role_policy_attachment" "app_ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "app_cw" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_iam_policy_document" "app_inline" {
  # 아티팩트(seed jar + CodeDeploy 번들) read
  statement {
    sid       = "ReadArtifacts"
    actions   = ["s3:GetObject", "s3:GetObjectVersion"]
    resources = ["${aws_s3_bucket.artifacts.arn}/*"]
  }
  statement {
    sid       = "ListArtifacts"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.artifacts.arn]
  }

  # 미디어 버킷 데이터플레인 RW — S3 Gateway Endpoint 경유 강제 (자격증명 유출 시 외부 직접 호출 차단)
  statement {
    sid       = "MediaReadWriteViaVpce"
    actions   = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.media.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceVpce"
      values   = [aws_vpc_endpoint.s3.id]
    }
  }
  statement {
    sid       = "MediaListViaVpce"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.media.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceVpce"
      values   = [aws_vpc_endpoint.s3.id]
    }
  }

  # DB password (SSM SecureString)
  statement {
    sid       = "ReadDbPassword"
    actions   = ["ssm:GetParameter", "ssm:GetParameters"]
    resources = [aws_ssm_parameter.db_password.arn]
  }
}

resource "aws_iam_role_policy" "app_inline" {
  name   = "${local.name_prefix}-app-inline"
  role   = aws_iam_role.app.id
  policy = data.aws_iam_policy_document.app_inline.json
}

resource "aws_iam_instance_profile" "app" {
  name = "${local.name_prefix}-app-profile"
  role = aws_iam_role.app.name
}
