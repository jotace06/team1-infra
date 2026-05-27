locals {
  # #3 그룹: 표준 Gateway API CRDs (Gateway, GatewayClass, HTTPRoute, GRPCRoute, ReferenceGrant 등)
  gateway_api_standard_url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v${var.gateway_api_version}/standard-install.yaml"

  # #2 그룹: AWS vended Gateway API CRDs (TargetGroupConfiguration, LoadBalancerConfiguration, ListenerRuleConfiguration)
  aws_vended_url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v${var.chart_version}/config/crd/gateway/gateway-crds.yaml"
}

# ─── #3 표준 Gateway API CRDs ───
data "http" "gateway_api_standard" {
  url = local.gateway_api_standard_url
}

data "kubectl_file_documents" "gateway_api_standard" {
  content = data.http.gateway_api_standard.response_body
}

resource "kubectl_manifest" "gateway_api_standard" {
  for_each          = data.kubectl_file_documents.gateway_api_standard.manifests
  yaml_body         = each.value
  server_side_apply = true
}

# ─── #2 AWS vended Gateway API CRDs ───
data "http" "aws_vended" {
  url = local.aws_vended_url
}

data "kubectl_file_documents" "aws_vended" {
  content = data.http.aws_vended.response_body
}

resource "kubectl_manifest" "aws_vended" {
  for_each          = data.kubectl_file_documents.aws_vended.manifests
  yaml_body         = each.value
  server_side_apply = true
}
