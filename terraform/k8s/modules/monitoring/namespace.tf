resource "kubernetes_manifest" "namespace_monitoring" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Namespace"
    "metadata" = {
      "name" = "monitoring"
    }
  }
}
