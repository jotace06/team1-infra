# ─── 공통 메타 ─────────────────────────────
variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "Environment name (dev | prod)"
  type        = string
}

variable "project_name" {
  description = "Project name, used in tags and resource names"
  type        = string
  default     = "course-registration"
}

variable "owner" {
  description = "Owner tag — person or team responsible"
  type        = string
}

# ─── 네트워크 ─────────────────────────────
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zones" {
  description = "AZs to use in this region"
  type        = list(string)
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways (1 for dev, AZ count for prod)"
  type        = number
}

# ─── 이 아래는 Step 3 이후 모듈 추가하면서 채울 자리 ─────────
# variable "rds_instance_class" { ... }
# variable "rds_multi_az"       { ... }
# variable "eks_cluster_version" { ... }
# variable "eks_node_count"     { ... }
