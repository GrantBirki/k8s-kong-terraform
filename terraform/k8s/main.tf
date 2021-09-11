# module "cert_manager" {
#   source = "./modules/cert-manager"
# }

module "kong" {
  source = "./modules/kong"
}

module "monitoring" {
  source = "./modules/monitoring"
}

module "nginx_example" {
  source = "./modules/containers/nginx_example"
}
