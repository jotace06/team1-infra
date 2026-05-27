output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority" {
  description = "Base64-encoded CA cert for the cluster"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL (needed for IRSA in 5b)"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "cluster_version" {
  description = "Kubernetes version"
  value       = aws_eks_cluster.this.version
}

output "node_role_arn" {
  description = "ARN of the IAM role attached to worker nodes"
  value       = aws_iam_role.node.arn
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider — used by IRSA role trust policies"
  value       = aws_iam_openid_connect_provider.this.arn
}

output "cluster_security_group_id" {
  description = "EKS-managed SG attached to all nodes — used to allow RDS access"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

# terraform destroy가 올바른 순서로 동작하게 하기 위한 수정 (1)
# EKS 모듈 안에서 만든 access entry/policy association을 외부 모듈이 의존성으로 잡으려면 output이 필요
output "cluster_admin_access_policy_association_id" {
  description = "Used by add-on modules to ensure they depend on cluster admin access being in place"
  value       = aws_eks_access_policy_association.admin.id
}
