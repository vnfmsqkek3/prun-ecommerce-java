# =============================================================================
# main.tf — furn e-commerce 3-tier (nanoh2o 컨벤션 미러링)
# 평탄 구조 (모듈 금지). 리소스는 서비스별 .tf 파일에 분리.
#   - vpc.tf            : VPC / Subnet / IGW / NAT / Route Tables (4 tier)
#   - security_group.tf : Security Groups (chain: api-alb→app→rds/redis)
#   - s3.tf             : 버킷 3종 (artifacts / static SPA / media)
#   - iam.tf            : Backend Instance Role / Profile (S3 read+미디어 RW + SSM)
#   - ssm.tf            : SSM Parameter Store (DB password SecureString)
#   - rds.tf            : RDS MySQL Multi-AZ
#   - elasticache.tf    : ElastiCache Redis (세션 저장소)
#   - alb.tf            : API ALB (internet-facing, CloudFront 오리진)
#   - cloudfront.tf     : CloudFront (정적 S3 / /media S3 / /api ALB 경로 분기)
#   - ec2.tf            : AMI(AL2023) lookup + EC2 Instance Connect Endpoint
#   - asg.tf            : Backend Launch Template + ASG + scaling policy (네이티브)
#   - cicd.tf           : CodePipeline (GitHub → CodeBuild → CodeDeploy/S3)
# 흐름: Internet → CloudFront ─┬─ 정적/미디어 → S3 (OAC)
#                              └─ /api,/actuator → API ALB → Backend ASG(Spring)
#                                                            → RDS MySQL + ElastiCache Redis
# =============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = title(var.environment)
      Project     = var.project
      Service     = "ecommerce"
      Username    = "czy1023"
    }
  }
}

# ---------- Data sources ----------
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

# ---------- Common locals ----------
# AZ 는 var.az_letters 로 명시 선택. suffix 는 region 약어 + 존문자 (ap-northeast-2a → an2a).
locals {
  name_prefix = "${var.project}-${var.environment}"
  ssm_prefix  = "/${var.project}/${var.environment}"
  azs         = [for letter in var.az_letters : "${var.aws_region}${letter}"]
  az_suffix = {
    for az in local.azs :
    az => "${substr(az, 0, 1)}${substr(az, 3, 1)}${substr(az, length(az) - 2, 2)}"
  }

  common_tags = {
    Environment = title(var.environment)
    Project     = var.project
    Service     = "ecommerce"
    Username    = "czy1023"
  }

  # S3 시드 아티팩트 키 — 최초 부팅 시 백엔드 user-data 가 받는 jar.
  # 이후 배포는 CodePipeline → CodeBuild → CodeDeploy(백엔드) / S3 sync(프론트).
  backend_seed_key = "seed/backend/app.jar"
  queue_seed_key   = "seed/queue/app.jar"
}
