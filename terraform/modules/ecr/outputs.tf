output "repository_url" {
  description = "ECR repository URL (used in docker push/pull and K8s Pod spec)"
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  description = "ECR repository ARN (used in IAM policies)"
  value       = aws_ecr_repository.this.arn
}

output "repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.this.name
}
