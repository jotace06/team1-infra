# Chart 버전과 매치되는 CRD YAML URL.
# kubernetes-sigs repo의 chart 태그 안 crds/crds.yaml 사용 → chart_version과 spec 자동 일치.
locals {
  crds_url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v${var.chart_version}/helm/aws-load-balancer-controller/crds/crds.yaml"
}

# YAML 원본 다운로드
data "http" "lbc_crds" {
  url = local.crds_url
}

# Multi-document YAML 자동 분리
data "kubectl_file_documents" "lbc_crds" {
  content = data.http.lbc_crds.response_body
}

# 각 CRD를 server-side apply로 적용
resource "kubectl_manifest" "lbc_crds" {
  for_each          = data.kubectl_file_documents.lbc_crds.manifests
  yaml_body         = each.value
  server_side_apply = true
}
