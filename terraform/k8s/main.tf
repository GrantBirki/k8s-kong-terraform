module "cert_manager" {
  source = "./modules/cert-manager"
}

module "kong" {
  source = "./modules/kong"
}

module "monitoring" {
  source = "./modules/monitoring"
}

module "nginx" {
  source = "./modules/containers/nginx"
  # Environment variables
  IMAGE_TAG   = var.NGINX_IMAGE_TAG
  ENVIRONMENT = var.ENVIRONMENT

  # Config
  ACR_NAME = data.azurerm_container_registry.acr.name
}
