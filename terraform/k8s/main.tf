module "cert_manager" {
  source = "./modules/cert-manager"
}

module "kong" {
  source = "./modules/kong"
  depends_on = [
    module.cert_manager
  ]
}

module "monitoring" {
  source = "./modules/monitoring"
}

module "nginx_example" {
  source = "./modules/containers/nginx_example"
}
