variable "role_name" {
  description = "IAM role name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider (from eks module output)"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider (without https://)"
  type        = string
}

variable "namespace" {
  description = "K8s namespace where the ServiceAccount lives"
  type        = string
}

variable "service_account_name" {
  description = "K8s ServiceAccount name that will assume this role"
  type        = string
}

variable "policy_arns" {
  description = "List of AWS managed or customer-managed policy ARNs to attach"
  type        = list(string)
  default     = []
}

variable "inline_policy_json" {
  description = "Optional inline policy JSON (for add-ons with custom policies like ALB Controller)"
  type        = string
  default     = null
}
