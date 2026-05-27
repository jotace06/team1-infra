resource "helm_release" "this" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = var.chart_version
  namespace  = var.namespace

  set = [
    {
      name  = "args[0]"
      value = "--kubelet-insecure-tls"
    },
  ]
}
