locals {
  name_prefix  = "${var.project_name}-${var.environment}"
  cluster_name = local.name_prefix
}

# Cluster(Control Plane)
resource "aws_eks_cluster" "this" {
  name     = local.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    # control plane ENI가 들어갈 subnet (public + private 모두)
    subnet_ids = concat(var.private_subnet_ids, var.public_subnet_ids)

    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  # 새 Access Entries API 모드로 시작
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }

  # IAM role이 먼저 만들어진 후 cluster 생성
  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
  ]

  tags = {
    Name = local.cluster_name
  }
}

# Access Entry
resource "aws_eks_access_entry" "admin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.cluster_admin_iam_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.cluster_admin_iam_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

# Managed Node Group
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${local.name_prefix}-ng"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnet_ids # ★ private subnet only

  instance_types = var.node_instance_types
  capacity_type  = "ON_DEMAND"
  disk_size      = 20 # GB, 기본 EBS

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_ecr_read,
  ]

  # scaling으로 노드 수 바뀌어도 Terraform이 desired_size를 강제로 되돌리지 않도록
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = {
    Name = "${local.name_prefix}-ng"
  }
}

# ─────────────────────────────────────────────
# IAM OIDC Identity Provider for IRSA
# ─────────────────────────────────────────────

data "tls_certificate" "cluster" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = {
    Name = "${local.name_prefix}-oidc"
  }
}
