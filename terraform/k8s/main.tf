module "kong" {
  source = "./modules/kong"
}

module "nginx_example" {
  source = "./modules/containers/nginx_example"
}
