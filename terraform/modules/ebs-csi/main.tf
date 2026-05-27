# ─── IRSA Role ───
module "irsa" {
  source = "../irsa-role"

  role_name            = "${var.cluster_name}-ebs-csi"
  oidc_provider_arn    = var.oidc_provider_arn
  oidc_provider_url    = var.oidc_provider_url
  namespace            = var.namespace
  service_account_name = var.service_account_name

  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ]
}

# ─── EKS Add-on ───
resource "aws_eks_addon" "this" {
  cluster_name                = var.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  service_account_role_arn    = module.irsa.role_arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [module.irsa]
}
