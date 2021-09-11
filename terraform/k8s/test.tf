resource "kubernetes_manifest" "kongclusterplugin_prometheus" {
  manifest = {
    "apiVersion" = "configuration.konghq.com/v1"
    "kind" = "KongClusterPlugin"
    "metadata" = {
      "annotations" = {
        "kubernetes.io/ingress.class" = "kong"
      }
      "labels" = {
        "global" = "true"
      }
      "name" = "prometheus"
    }
    "plugin" = "prometheus"
  }
}

resource "kubernetes_manifest" "kongplugin_monitoring_ip_allowlist" {
  manifest = {
    "apiVersion" = "configuration.konghq.com/v1"
    "config" = {
      "allow" = [
        "123.123.123.123/32",
      ]
    }
    "kind" = "KongPlugin"
    "metadata" = {
      "name" = "ip-allowlist"
      "namespace" = "monitoring"
    }
    "plugin" = "ip-restriction"
  }
}
