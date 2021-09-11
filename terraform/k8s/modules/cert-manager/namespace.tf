resource "kubernetes_manifest" "namespace_cert_manager" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Namespace"
    "metadata" = {
      "name" = "cert-manager"
    }
  }
}
