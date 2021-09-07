# Uncomment if you want the "request-id" Kong plugin to be enabled
#
# resource "kubernetes_manifest" "kongplugin_request_id" {
#   manifest = {
#     "apiVersion" = "configuration.konghq.com/v1"
#     "config" = {
#       "header_name" = "x-request-id"
#       "echo_downstream" = "true"
#     }
#     "kind" = "KongPlugin"
#     "metadata" = {
#       "name"      = "request-id"
#       "namespace" = "kong"
#     }
#     "plugin" = "correlation-id"
#   }
# }