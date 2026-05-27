variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "database_subnet_ids" {
  description = "Subnet IDs for RDS (must span >= 2 AZs)"
  type        = list(string)
}

variable "allowed_security_group_id" {
  description = "Source SG allowed to connect on port 3306 (EKS cluster SG)"
  type        = string
}

variable "engine_version" {
  type    = string
  default = "8.0.40"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Initial storage in GB (gp3)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Storage autoscaling cap in GB"
  type        = number
  default     = 100
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "backup_retention_days" {
  description = "0 disables automated backups (dev), 7+ for prod"
  type        = number
  default     = 0
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "skip_final_snapshot" {
  description = "If true, no snapshot taken on destroy (dev convenience)"
  type        = bool
  default     = true
}

variable "database_name" {
  type    = string
  default = "course_registration"
}

variable "master_username" {
  type    = string
  default = "admin"
}
