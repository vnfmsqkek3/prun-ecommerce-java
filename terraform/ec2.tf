# =============================================================================
# ec2.tf — AMI lookup + EC2 Instance Connect Endpoint
# ASG 인스턴스는 AL2023 위에서 docker 로 ECR 이미지를 구동 (asg.tf user-data).
# =============================================================================

# ASG 런치 템플릿이 사용할 Amazon Linux 2023 latest AMI
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ---------- EC2 Instance Connect Endpoint ----------
# Bastion 없이 콘솔/CLI 로 private web/app 인스턴스 SSH 접근 (단일 endpoint 가 VPC 커버).
resource "aws_ec2_instance_connect_endpoint" "main" {
  subnet_id          = aws_subnet.private_app[local.azs[0]].id
  security_group_ids = [aws_security_group.eice.id]
  preserve_client_ip = false
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-pri-eice"
  })
}
