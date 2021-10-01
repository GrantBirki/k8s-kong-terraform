variable "ENVIRONMENT" {
  description = "The Environment context which all containers are running in (dev/prod)"
  type        = string
  default     = "prod"
}

variable "NGINX_IMAGE_TAG" {
  description = "The image tag to use for backend deployments"
  default     = "latest"
  type        = string
}

# Azure Creds
variable "CLIENT_SECRET" {
  type = string
}

variable "CLIENT_ID" {
  type = string
}

variable "TENANT_ID" {
  type = string
}

variable "SUBSCRIPTION_ID" {
  type = string
}
