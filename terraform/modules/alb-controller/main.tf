# ─── IRSA Role ───
module "irsa" {
  source = "../irsa-role"

  role_name            = "${var.cluster_name}-alb-controller"
  oidc_provider_arn    = var.oidc_provider_arn
  oidc_provider_url    = var.oidc_provider_url
  namespace            = var.namespace
  service_account_name = var.service_account_name

  inline_policy_json = file("${path.module}/policies/iam_policy.json")
}

# ─── Helm release ───
resource "helm_release" "this" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.chart_version
  namespace  = var.namespace

  set = [ # ← 리스트로 변경
    {
      name  = "clusterName"
      value = var.cluster_name
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = var.service_account_name
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.irsa.role_arn
    },
    {
      name  = "region"
      value = var.aws_region
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    },
  ]

  depends_on = [module.irsa]
}
