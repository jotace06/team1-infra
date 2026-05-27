variable "project_name" {
  description = "Project name, used as a prefix for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name (dev | prod)"
  type        = string
}

variable "untagged_image_expiration_days" {
  description = "Days after which untagged images are deleted"
  type        = number
  default     = 1
}

variable "max_tagged_images" {
  description = "Maximum number of tagged images to retain"
  type        = number
  default     = 10
}
