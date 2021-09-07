resource "kubernetes_ingress" "example_ingress" {
  # Wait for Kong to deploy
  depends_on = [
    kubernetes_manifest.namespace_kong
  ]

  metadata {
    name = "example"
    annotations = {
      "konghq.com/strip-path"       = "true"
      "kubernetes.io/ingress.class" = "kong"
      # "konghq.com/plugins"          = "request-id" # Uncomment if you want the "request-id" Kong plugin to be enabled
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/"
          backend {
            service_name = "example"
            service_port = 80
          }
        }
      }
    }
  }
}
