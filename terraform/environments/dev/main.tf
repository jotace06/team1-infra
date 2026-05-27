module "vpc" {
  source = "../../modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  nat_gateway_count  = var.nat_gateway_count
}

module "ecr" {
  source = "../../modules/ecr"

  project_name = var.project_name
  environment  = var.environment

  untagged_image_expiration_days = 1
  max_tagged_images              = 10
}

module "eks" {
  source = "../../modules/eks"

  project_name    = var.project_name
  environment     = var.environment
  cluster_version = "1.31"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids # ← 아래 메모

  node_instance_types = ["t3.medium"]
  node_desired_size   = 2
  node_min_size       = 1
  node_max_size       = 4

  cluster_admin_iam_arn = var.cluster_admin_iam_arn
}

# OIDC URL에서 https:// 제거한 버전 (IRSA condition에 쓰임)
locals {
  oidc_provider_url = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
}

# terraform destroy가 올바른 순서로 동작하게 하기 위한 수정 (2)
module "alb_controller" {
  source = "../../modules/alb-controller"

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = local.oidc_provider_url
  vpc_id            = module.vpc.vpc_id
  aws_region        = var.aws_region

  chart_version = "3.3.0"

  # ★ 추가: admin 권한이 살아있는 동안에만 Helm operation 가능
  depends_on = [module.eks]
}

# terraform destroy가 올바른 순서로 동작하게 하기 위한 수정 (3)
module "ebs_csi" {
  source = "../../modules/ebs-csi"

  cluster_name      = module.eks.cluster_name
  cluster_version   = "1.31"
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = local.oidc_provider_url

  # ★ 추가
  depends_on = [module.eks]
}

# terraform destroy가 올바른 순서로 동작하게 하기 위한 수정 (4)
module "metrics_server" {
  source = "../../modules/metrics-server"

  # ★ 추가
  depends_on = [module.eks]
}

module "rds" {
  source = "../../modules/rds"

  project_name = var.project_name
  environment  = var.environment

  vpc_id                    = module.vpc.vpc_id
  database_subnet_ids       = module.vpc.database_subnet_ids
  allowed_security_group_id = module.eks.cluster_security_group_id

  instance_class    = "db.t3.micro"
  allocated_storage = 20
  multi_az          = false

  backup_retention_days = 0
  deletion_protection   = false
  skip_final_snapshot   = true

  database_name = "course_registration"

  # ★ 추가 (이미 변수로 암시적 의존성 있지만 명시적이면 안전)
  depends_on = [module.eks]
}
