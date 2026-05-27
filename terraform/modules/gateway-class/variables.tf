variable "name" {
  description = "GatewayClass name"
  type        = string
  default     = "alb"
}

variable "controller_name" {
  description = "Controller name that this GatewayClass binds to"
  type        = string
  default     = "gateway.k8s.aws/alb" # AWS LBC v3.x
}
