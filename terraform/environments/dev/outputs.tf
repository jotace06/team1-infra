output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  value = module.vpc.database_subnet_ids
}

# ECR
output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "alb_controller_role_arn" {
  value = module.alb_controller.role_arn
}

output "ebs_csi_role_arn" {
  value = module.ebs_csi.role_arn
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "rds_secret_arn" {
  value = module.rds.master_user_secret_arn
}
