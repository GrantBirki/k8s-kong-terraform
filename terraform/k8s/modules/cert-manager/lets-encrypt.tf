resource "kubernetes_manifest" "clusterissuer_letsencrypt_prod" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt-prod"
    }
    "spec" = {
      "acme" = {
        "email" = "<example-email@example.com>" # Put your own email here
        "privateKeySecretRef" = {
          # Secret resource that will be used to store the account's private key.
          "name" = "letsencrypt-prod-issuer-account-key"
        }
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "solvers" = [
          {
            "http01" = {
              "ingress" = {
                "class" = "kong"
              }
            }
          },
        ]
      }
    }
  }
}
