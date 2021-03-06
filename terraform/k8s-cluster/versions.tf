terraform {
  backend "remote" {
    organization = "birki-io" # Change this to your own organization (CHANGE ME)

    workspaces {
      name = "k8s-cluster-testing" # Change this to your own workspace name (CHANGE ME)
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.66.0"
    }
  }

  required_version = "=1.0.6" # Change this to a different version if you want
}
