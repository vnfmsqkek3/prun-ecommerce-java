# =============================================================================
# iam.tf — EC2 Instance Roles / Profiles (최소 권한)
#   web  : S3 아티팩트 read + SSM Session Manager + CloudWatch agent
#   app  : web 권한 + DB password SSM parameter 읽기
# (CI/CD 서비스 롤 — CodeBuild/CodeDeploy/CodePipeline — 은 cicd.tf 에 있음)
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

# 인스턴스가 S3 아티팩트(seed + CodeDeploy 번들) 를 읽기 위한 공통 정책
data "aws_iam_policy_document" "instance_artifacts" {
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
}

# ---------- Frontend (web) role ----------
resource "aws_iam_role" "web" {
  name               = "${local.name_prefix}-web-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
  tags               = merge(local.common_tags, { Name = "${local.name_prefix}-web-role" })
}

resource "aws_iam_role_policy" "web_artifacts" {
  name   = "${local.name_prefix}-web-artifacts"
  role   = aws_iam_role.web.id
  policy = data.aws_iam_policy_document.instance_artifacts.json
}

resource "aws_iam_role_policy_attachment" "web_ssm" {
  role       = aws_iam_role.web.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "web_cw" {
  role       = aws_iam_role.web.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "web" {
  name = "${local.name_prefix}-web-profile"
  role = aws_iam_role.web.name
}

# ---------- Backend (app) role ----------
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

# S3 아티팩트 read + DB password (SSM SecureString) 읽기
data "aws_iam_policy_document" "app_inline" {
  source_policy_documents = [data.aws_iam_policy_document.instance_artifacts.json]

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
