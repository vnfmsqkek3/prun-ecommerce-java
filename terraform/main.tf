# =============================================================================
# main.tf — furn e-commerce 3-tier (nanoh2o 컨벤션 미러링)
# 평탄 구조 (모듈 금지). 리소스는 서비스별 .tf 파일에 분리.
#   - vpc.tf            : VPC / Subnet / IGW / NAT / Route Tables (5 tier)
#   - security_group.tf : Security Groups (chain: web-alb→web→back-alb→app→rds/redis)
#   - s3.tf             : 아티팩트 버킷 (seed + CodePipeline 저장소)
#   - iam.tf            : EC2 Instance Roles / Profiles (S3 아티팩트 read + SSM)
#   - ssm.tf            : SSM Parameter Store (DB password SecureString)
#   - rds.tf            : RDS MySQL Multi-AZ
#   - elasticache.tf    : ElastiCache Redis (세션 저장소)
#   - alb.tf            : Public ALB(web) + Internal ALB(back)
#   - cloudfront.tf     : CloudFront CDN (Public ALB 앞단)
#   - ec2.tf            : AMI(AL2023) lookup + EC2 Instance Connect Endpoint
#   - asg.tf            : Launch Template + ASG + scaling policy (web / app, 네이티브)
#   - cicd.tf           : CodePipeline (GitHub → CodeBuild → CodeDeploy)
# 3-tier 흐름: Internet → Public ALB → Frontend ASG(nginx)
#              → Internal ALB → Backend ASG(Spring) → RDS MySQL + ElastiCache Redis
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
  }

  # S3 시드 아티팩트 키 — 최초 부팅 시 user-data 가 받는 코드.
  # 이후 배포는 CodePipeline → CodeBuild → CodeDeploy 가 ASG 인스턴스에 직접 배포.
  backend_seed_key  = "seed/backend/app.jar"
  frontend_seed_key = "seed/frontend/dist.tar.gz"
}
