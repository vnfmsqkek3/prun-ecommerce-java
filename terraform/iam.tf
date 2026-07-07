# =============================================================================
# iam.tf — Backend EC2 Instance Role / Profile (최소 권한)
#   app : SSM Session Manager(core) + CloudWatch agent(관리형)
#         + 인라인: S3 아티팩트 read, 미디어 RW(S3 endpoint 강제),
#           SSM param(/furn/prod/*) read, KMS decrypt(ssm/s3 경유)
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

  # SSM Parameter Store — 프로젝트 prefix(/furn/prod/*) 전체 읽기 (현재 db password, 향후 config 확장)
  statement {
    sid     = "ReadAppConfigSsm"
    actions = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]
    resources = [
      "arn:${data.aws_partition.current.partition}:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter${local.ssm_prefix}",
      "arn:${data.aws_partition.current.partition}:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter${local.ssm_prefix}/*",
    ]
  }

  # KMS — SSM SecureString 복호화 + (향후) S3 SSE-KMS 복호화. ssm/s3 서비스 경유로만 제한.
  statement {
    sid       = "KmsDecryptViaSsmS3"
    actions   = ["kms:Decrypt", "kms:GenerateDataKey", "kms:DescribeKey"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "ssm.${var.aws_region}.amazonaws.com",
        "s3.${var.aws_region}.amazonaws.com",
      ]
    }
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
