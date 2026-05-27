variable "project_name" {
  description = "Project name, used as a prefix for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name (dev | prod)"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "vpc_id" {
  description = "VPC ID where the cluster lives"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for worker nodes"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs (EKS uses these for control plane ENI)"
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance types for worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDRs allowed to access the cluster API publicly"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_admin_iam_arn" {
  description = "IAM principal ARN to grant cluster admin (your IAM user)"
  type        = string
}
