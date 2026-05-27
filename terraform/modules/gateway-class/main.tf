resource "kubectl_manifest" "gateway_class" {
  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "GatewayClass"
    metadata = {
      name = var.name
    }
    spec = {
      controllerName = var.controller_name
    }
  })

  server_side_apply = true
}
