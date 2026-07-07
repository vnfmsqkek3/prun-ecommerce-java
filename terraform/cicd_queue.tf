# =============================================================================
# cicd_queue.tf — 대기열 서버 CI/CD (backend 파이프라인과 동일 구조, 롤 재사용)
#   Source(GitHub) → Build(queue-server/buildspec.yml) → CodeDeploy(queue ASG)
# =============================================================================

resource "aws_codebuild_project" "queue" {
  name         = "${local.name_prefix}-build-queue"
  service_role = aws_iam_role.codebuild.arn

  artifacts { type = "CODEPIPELINE" }
  source {
    type      = "CODEPIPELINE"
    buildspec = "queue-server/buildspec.yml"
  }
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = var.codebuild_image
    type            = "LINUX_CONTAINER"
    privileged_mode = false
  }
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-build-queue" })
}

resource "aws_codedeploy_app" "queue" {
  name             = "${local.name_prefix}-queue"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "queue" {
  app_name               = aws_codedeploy_app.queue.name
  deployment_group_name  = "${local.name_prefix}-queue-dg"
  service_role_arn       = aws_iam_role.codedeploy.arn
  autoscaling_groups     = [aws_autoscaling_group.queue.name]
  deployment_config_name = "CodeDeployDefault.OneAtATime"

  deployment_style {
    deployment_type   = "IN_PLACE"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }
  load_balancer_info {
    target_group_info { name = aws_lb_target_group.queue.name }
  }
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}

resource "aws_codepipeline" "queue" {
  name     = "${local.name_prefix}-queue-pipeline"
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
      configuration    = { ProjectName = aws_codebuild_project.queue.name }
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
        ApplicationName     = aws_codedeploy_app.queue.name
        DeploymentGroupName = aws_codedeploy_deployment_group.queue.deployment_group_name
      }
    }
  }
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-queue-pipeline" })
}
