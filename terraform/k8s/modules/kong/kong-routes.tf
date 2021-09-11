resource "kubernetes_manifest" "ingress_example" {
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind"       = "Ingress"
    "metadata" = {
      "annotations" = {
        "konghq.com/strip-path" = "true"
        # "konghq.com/plugins"             = "ip-allowlist" # Uncomment to enable IP allowlist plugin
        # "cert-manager.io/cluster-issuer" = "letsencrypt-prod" # Uncomment to enable TLS
        # "kubernetes.io/tls-acme"         = "true" # Uncomment to enable TLS
      }
      "name" = "example"
    }
    "spec" = {
      "ingressClassName" = "kong"
      "rules" = [
        {
          # "host" = "<www.example.com>" # Uncomment to enable hostname (needed if you enable the external Grafana section below)
          "http" = {
            "paths" = [
              {
                "backend" = {
                  "service" = {
                    "name" = "example"
                    "port" = {
                      "number" = 80
                    }
                  }
                }
                "path"     = "/"
                "pathType" = "Prefix"
              },
            ]
          }
        },
      ]
      # "tls" = [ # Uncomment to enable TLS
      #   { # Uncomment to enable TLS
      #     "hosts" = [ # Uncomment to enable TLS
      #       "<www.example.com>", # Uncomment to enable TLS
      #     ] # Uncomment to enable TLS
      #     "secretName" = "letsencrypt-prod-issuer-account-key" # Uncomment to enable TLS
      #   }, # Uncomment to enable TLS
      # ] # Uncomment to enable TLS
    }
  }
}

# Un comment the 'resource' block below to expose your Grafana dashboard publically
# Note: It is highly recommended to use the IP allowlist plugin to limit access to the dashboard
# Note2: It is highly recommended to enable the TLS sections as well + the letsencrypt-prod issuer
#
# resource "kubernetes_manifest" "ingress_monitoring_monitoring" {
#   manifest = {
#     "apiVersion" = "networking.k8s.io/v1"
#     "kind"       = "Ingress"
#     "metadata" = {
#       "annotations" = {
#         "konghq.com/strip-path" = "true"
#         "konghq.com/plugins"    = "ip-allowlist" # Comment to disable IP allowlist plugin
#         # "kubernetes.io/tls-acme"         = "true" # Uncomment to enable TLS
#         # "cert-manager.io/cluster-issuer" = "letsencrypt-prod" # Uncomment to enable TLS
#       }
#       "name"      = "monitoring"
#       "namespace" = "monitoring"
#     }
#     "spec" = {
#       "ingressClassName" = "kong"
#       "rules" = [
#         {
#           "host" = "<grafana.example.com>"
#           "http" = {
#             "paths" = [
#               {
#                 "backend" = {
#                   "service" = {
#                     "name" = "grafana"
#                     "port" = {
#                       "number" = 80
#                     }
#                   }
#                 }
#                 "path"     = "/"
#                 "pathType" = "Prefix"
#               },
#             ]
#           }
#         },
#       ]
#       # "tls" = [ # Uncomment to enable TLS
#       #   { # Uncomment to enable TLS
#       #     "hosts" = [ # Uncomment to enable TLS
#       #       "<grafana.example.com>", # Uncomment to enable TLS
#       #     ] # Uncomment to enable TLS
#       #     "secretName" = "letsencrypt-prod-issuer-account-key" # Uncomment to enable TLS
#       #   }, # Uncomment to enable TLS
#       # ] # Uncomment to enable TLS
#     }
#   }
# }
