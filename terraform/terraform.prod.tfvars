# =============================================================================
# terraform.prod.tfvars — furn prod
# =============================================================================

# Project / Region
aws_region  = "ap-northeast-2" # Seoul (앱 타임존 Asia/Seoul 과 일치)
environment = "prod"
project     = "furn"

# Network — /20 (4096 IP), 5 tier × 2 AZ = 10 subnets (각 /24)
vpc_cidr   = "10.100.0.0/20"
az_letters = ["a", "c"] # ap-northeast-2a, ap-northeast-2c → suffix "an2a", "an2c"

# keyless — 접속은 EC2 Instance Connect Endpoint 로. (key pair 쓰려면 ssh_key_name 설정)

# CI/CD (CodePipeline · GitHub)
github_owner  = "vnfmsqkek3"
github_repo   = "prun-ecommerce-java"
github_branch = "main"

# Backend (app) ASG
app_instance_type              = "m5.large"
app_asg_min_size               = 2
app_asg_max_size               = 4
app_asg_desired_capacity       = 2
app_asg_target_cpu_utilization = 70

# RDS MySQL Multi-AZ
db_instance_class       = "db.t3.small"
db_engine_version       = "8.0.42"
db_allocated_storage_gb = 50
db_name                 = "ticketing"
db_master_username      = "furnadmin"
db_multi_az             = true
# 데모 기본값(간편 destroy). 실운영은 아래 두 줄을 true / false 로.
db_deletion_protection = false
db_skip_final_snapshot = true

# ElastiCache Redis (Spring Session)
redis_engine_version       = "7.1"
redis_node_type            = "cache.t3.small"
redis_parameter_group_name = "default.redis7"

# CloudFront
cloudfront_price_class = "PriceClass_200"
