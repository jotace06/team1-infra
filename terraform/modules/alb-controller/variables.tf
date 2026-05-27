variable "cluster_name" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_provider_url" {
  description = "OIDC URL without https:// prefix"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "chart_version" {
  description = "Helm chart version for aws-load-balancer-controller"
  type        = string
  default     = "1.8.2" # corresponds to controller v2.8.2
}

variable "namespace" {
  type    = string
  default = "kube-system"
}

variable "service_account_name" {
  type    = string
  default = "aws-load-balancer-controller"
}

variable "skip_crds" {
  description = "Skip CRDs installation by Helm chart (if managed separately, e.g., via modules/lbc-crds)"
  type        = bool
  default     = false
}
