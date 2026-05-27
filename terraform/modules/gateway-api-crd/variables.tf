variable "chart_version" {
  description = "LBC chart version (for AWS vended Gateway API CRDs)"
  type        = string
}

variable "gateway_api_version" {
  description = "Standard Gateway API spec version (kubernetes-sigs/gateway-api)"
  type        = string
  default     = "1.5.0"
}
