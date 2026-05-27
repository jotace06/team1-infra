variable "role_name" {
  description = "Name of the IAM role (e.g., 'github-actions-team1-app-dev')"
  type        = string
}

variable "repo" {
  description = "GitHub repository in '<owner>/<name>' format (for description/tagging)"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider (from github-oidc-provider module)"
  type        = string
}

variable "github_subject_claims" {
  description = <<-EOT
    List of GitHub OIDC 'sub' claim patterns allowed to assume this role.
    Use the most specific pattern possible. Examples:
      - "repo:owner/repo:ref:refs/heads/develop"     (branch-specific)
      - "repo:owner/repo:pull_request"               (PRs)
      - "repo:owner/repo:environment:dev"            (GitHub environment)
      - "repo:owner/repo:*"                          (DANGEROUS — any ref/event)
  EOT
  type        = list(string)
}

variable "ecr_repository_arns" {
  description = "List of ECR repository ARNs this role can push to"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
