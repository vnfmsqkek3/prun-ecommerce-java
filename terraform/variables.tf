# =============================================================================
# variables.tf — furn e-commerce 3-tier
# 모든 설정값/스케일링 정책/헬스 체크는 여기서 파라미터화
# =============================================================================

# ---------- Project / Region ----------
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "project" {
  description = "Project name used in resource naming"
  type        = string
  default     = "furn"
}

# ---------- Network ----------
variable "vpc_cidr" {
  description = "VPC CIDR (10.100.0.0/20 — 4096 IP, /24 subnet 16개 중 5 tier × 2 AZ = 10개 사용)"
  type        = string
  default     = "10.100.0.0/20"
}

variable "az_letters" {
  description = "사용할 AZ 글자 (aws_region 과 결합). 예: [\"a\", \"c\"]"
  type        = list(string)
  default     = ["a", "c"]
  validation {
    condition     = length(var.az_letters) == 2
    error_message = "정확히 2개 AZ 필요 (Multi-AZ)."
  }
}

# ---------- SSH ----------
variable "ssh_key_name" {
  description = "EC2 key pair name. 빈 값이면 keyless (EC2 Instance Connect Endpoint 로 접속)."
  type        = string
  default     = ""
}

# ---------- CI/CD (CodePipeline / GitHub) ----------
variable "github_owner" {
  description = "GitHub owner/org (예: my-org)"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name (frontend/ 와 backend/ 를 포함하는 단일 repo)"
  type        = string
}

variable "github_branch" {
  description = "파이프라인이 트리거되는 브랜치"
  type        = string
  default     = "main"
}

variable "codebuild_image" {
  description = "CodeBuild 표준 이미지 (Corretto17 + Node 포함)"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}

# ---------- Backend (app tier) ASG ----------
variable "app_instance_type" {
  description = "Backend EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "app_root_volume_size_gb" {
  description = "Backend EBS gp3 root volume size in GB"
  type        = number
  default     = 30
}

variable "app_asg_min_size" {
  description = "Backend ASG minimum size"
  type        = number
  default     = 2
}

variable "app_asg_max_size" {
  description = "Backend ASG maximum size"
  type        = number
  default     = 6
}

variable "app_asg_desired_capacity" {
  description = "Backend ASG desired capacity"
  type        = number
  default     = 2
}

variable "app_asg_target_cpu_utilization" {
  description = "Backend ASG target tracking CPU utilization (%)"
  type        = number
  default     = 60
}

variable "asg_health_check_grace_seconds" {
  description = "ASG ELB health check grace period in seconds (컨테이너 부팅 여유)"
  type        = number
  default     = 300
}

# ---------- ALB (공통 health check 설정) ----------
variable "alb_idle_timeout_seconds" {
  description = "ALB idle timeout in seconds"
  type        = number
  default     = 60
}

variable "back_health_check_path" {
  description = "API ALB → backend 헬스 체크 경로 (Spring actuator)"
  type        = string
  default     = "/actuator/health"
}

variable "alb_health_check_healthy_threshold" {
  description = "ALB health check healthy threshold"
  type        = number
  default     = 2
}

variable "alb_health_check_unhealthy_threshold" {
  description = "ALB health check unhealthy threshold"
  type        = number
  default     = 3
}

variable "alb_health_check_interval_seconds" {
  description = "ALB health check interval in seconds"
  type        = number
  default     = 30
}

variable "alb_health_check_timeout_seconds" {
  description = "ALB health check timeout in seconds"
  type        = number
  default     = 5
}

# ---------- RDS ----------
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.small"
}

variable "db_engine_version" {
  description = "RDS MySQL engine version"
  type        = string
  default     = "8.0.42"
}

variable "db_parameter_group_family" {
  description = "RDS parameter group family"
  type        = string
  default     = "mysql8.0"
}

variable "db_allocated_storage_gb" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 50
}

variable "db_name" {
  description = "Initial database name (application-prod.properties DB_NAME 기본값과 일치)"
  type        = string
  default     = "ecommerce_prod"
}

variable "db_master_username" {
  description = "RDS master username"
  type        = string
  default     = "furnadmin"
}

variable "db_multi_az" {
  description = "RDS Multi-AZ 활성화"
  type        = bool
  default     = true
}

variable "db_deletion_protection" {
  description = "RDS 삭제 보호. 데모는 false(간편 destroy), 실운영은 true 권장."
  type        = bool
  default     = false
}

variable "db_skip_final_snapshot" {
  description = "RDS destroy 시 최종 스냅샷 생략. 데모는 true, 실운영은 false 권장."
  type        = bool
  default     = true
}

# ---------- ElastiCache (Redis, 세션 저장소) ----------
variable "redis_engine_version" {
  description = "ElastiCache Redis engine version"
  type        = string
  default     = "7.1"
}

variable "redis_node_type" {
  description = "ElastiCache Redis node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_parameter_group_name" {
  description = "ElastiCache Redis parameter group (엔진 버전과 일치)"
  type        = string
  default     = "default.redis7"
}

# ---------- CloudFront ----------
variable "cloudfront_price_class" {
  description = "CloudFront price class (PriceClass_100/200/All)"
  type        = string
  default     = "PriceClass_200"
}
