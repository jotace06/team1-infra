variable "project_name" {
  description = "Project name, used as a prefix for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name (dev | prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones to span"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 AZs are required (RDS subnet group requirement)."
  }
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways (1 for dev cost saving, AZ count for prod HA)"
  type        = number

  validation {
    condition     = var.nat_gateway_count >= 1
    error_message = "At least 1 NAT Gateway is required for private subnet egress."
  }
}
