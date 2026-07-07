# =============================================================================
# cicd.tf — CodePipeline CI/CD (GitHub source, 단일 repo 서브폴더 빌드)
#   frontend : Source(GitHub) → Build(CodeBuild: npm build + S3 sync + CF 무효화)
#   backend  : Source(GitHub) → Build(CodeBuild: jar 번들) → Deploy(CodeDeploy, ASG 인플레이스)
# =============================================================================

# ---------- GitHub 연결 (콘솔에서 최초 1회 'Pending → Available' 수동 승인 필요) ----------
resource "aws_codestarconnections_connection" "github" {
  name          = "${local.name_prefix}-github"
  provider_type = "GitHub"
  tags          = merge(local.common_tags, { Name = "${local.name_prefix}-github" })
}

# =============================================================================
# CodeBuild
# =============================================================================
data "aws_iam_policy_document" "codebuild_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild" {
  name               = "${local.name_prefix}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume.json
  tags               = merge(local.common_tags, { Name = "${local.name_prefix}-codebuild-role" })
}

data "aws_iam_policy_document" "codebuild_inline" {
  statement {
    sid       = "Logs"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }
  # 파이프라인 아티팩트
  statement {
    sid       = "PipelineArtifacts"
    actions   = ["s3:GetObject", "s3:GetObjectVersion", "s3:PutObject", "s3:GetBucketLocation", "s3:ListBucket"]
    resources = [aws_s3_bucket.artifacts.arn, "${aws_s3_bucket.artifacts.arn}/*"]
  }
  # 프론트 정적 S3 sync
  statement {
    sid       = "StaticSync"
    actions   = ["s3:PutObject", "s3:DeleteObject", "s3:GetObject", "s3:ListBucket"]
    resources = [aws_s3_bucket.static.arn, "${aws_s3_bucket.static.arn}/*"]
  }
  # 프론트 배포 후 CloudFront 캐시 무효화
  statement {
    sid       = "Invalidate"
    actions   = ["cloudfront:CreateInvalidation"]
    resources = [aws_cloudfront_distribution.main.arn]
  }
}

resource "aws_iam_role_policy" "codebuild_inline" {
  name   = "${local.name_prefix}-codebuild-inline"
  role   = aws_iam_role.codebuild.id
  policy = data.aws_iam_policy_document.codebuild_inline.json
}

resource "aws_codebuild_project" "frontend" {
  name         = "${local.name_prefix}-build-frontend"
  service_role = aws_iam_role.codebuild.arn

  artifacts { type = "CODEPIPELINE" }
  source {
    type      = "CODEPIPELINE"
    buildspec = "frontend/buildspec.yml"
  }
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = var.codebuild_image
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      name  = "STATIC_BUCKET"
      value = aws_s3_bucket.static.bucket
    }
    environment_variable {
      name  = "CF_DIST_ID"
      value = aws_cloudfront_distribution.main.id
    }
  }
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-build-frontend" })
}

resource "aws_codebuild_project" "backend" {
  name         = "${local.name_prefix}-build-backend"
  service_role = aws_iam_role.codebuild.arn

  artifacts { type = "CODEPIPELINE" }
  source {
    type      = "CODEPIPELINE"
    buildspec = "backend/buildspec.yml"
  }
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = var.codebuild_image
    type            = "LINUX_CONTAINER"
    privileged_mode = false
  }
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-build-backend" })
}

# =============================================================================
# CodeDeploy (backend only — Server 플랫폼, ASG 인플레이스 + TG 트래픽 제어)
# =============================================================================
data "aws_iam_policy_document" "codedeploy_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codedeploy" {
  name               = "${local.name_prefix}-codedeploy-role"
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume.json
  tags               = merge(local.common_tags, { Name = "${local.name_prefix}-codedeploy-role" })
}

resource "aws_iam_role_policy_attachment" "codedeploy" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_codedeploy_app" "backend" {
  name             = "${local.name_prefix}-backend"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "backend" {
  app_name               = aws_codedeploy_app.backend.name
  deployment_group_name  = "${local.name_prefix}-app-dg"
  service_role_arn       = aws_iam_role.codedeploy.arn
  autoscaling_groups     = [aws_autoscaling_group.app.name]
  deployment_config_name = "CodeDeployDefault.OneAtATime"

  deployment_style {
    deployment_type   = "IN_PLACE"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }
  load_balancer_info {
    target_group_info {
      name = aws_lb_target_group.api.name
    }
  }
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}

# =============================================================================
# CodePipeline
# =============================================================================
data "aws_iam_policy_document" "codepipeline_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codepipeline" {
  name               = "${local.name_prefix}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume.json
  tags               = merge(local.common_tags, { Name = "${local.name_prefix}-codepipeline-role" })
}

data "aws_iam_policy_document" "codepipeline_inline" {
  statement {
    sid       = "Artifacts"
    actions   = ["s3:GetObject", "s3:GetObjectVersion", "s3:PutObject", "s3:GetBucketLocation", "s3:ListBucket"]
    resources = [aws_s3_bucket.artifacts.arn, "${aws_s3_bucket.artifacts.arn}/*"]
  }
  statement {
    sid       = "UseGithubConnection"
    actions   = ["codestar-connections:UseConnection"]
    resources = [aws_codestarconnections_connection.github.arn]
  }
  statement {
    sid       = "Build"
    actions   = ["codebuild:StartBuild", "codebuild:BatchGetBuilds"]
    resources = [aws_codebuild_project.frontend.arn, aws_codebuild_project.backend.arn, aws_codebuild_project.queue.arn]
  }
  statement {
    sid = "Deploy"
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:RegisterApplicationRevision",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codepipeline_inline" {
  name   = "${local.name_prefix}-codepipeline-inline"
  role   = aws_iam_role.codepipeline.id
  policy = data.aws_iam_policy_document.codepipeline_inline.json
}

# ---------- Frontend pipeline (Source → Build[S3 sync + CF 무효화]) ----------
resource "aws_codepipeline" "frontend" {
  name     = "${local.name_prefix}-frontend-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.artifacts.bucket
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source"]
      configuration = {
        ConnectionArn        = aws_codestarconnections_connection.github.arn
        FullRepositoryId     = "${var.github_owner}/${var.github_repo}"
        BranchName           = var.github_branch
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      configuration = {
        ProjectName = aws_codebuild_project.frontend.name
      }
    }
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-frontend-pipeline" })
}

# ---------- Backend pipeline (Source → Build → CodeDeploy) ----------
resource "aws_codepipeline" "backend" {
  name     = "${local.name_prefix}-backend-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.artifacts.bucket
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source"]
      configuration = {
        ConnectionArn        = aws_codestarconnections_connection.github.arn
        FullRepositoryId     = "${var.github_owner}/${var.github_repo}"
        BranchName           = var.github_branch
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["build"]
      configuration = {
        ProjectName = aws_codebuild_project.backend.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts = ["build"]
      configuration = {
        ApplicationName     = aws_codedeploy_app.backend.name
        DeploymentGroupName = aws_codedeploy_deployment_group.backend.deployment_group_name
      }
    }
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-backend-pipeline" })
}
