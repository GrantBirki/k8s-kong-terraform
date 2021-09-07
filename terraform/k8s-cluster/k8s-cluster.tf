resource "random_pet" "prefix" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "default" {
  name     = "${random_pet.prefix.id}-rg" # Change the name here if you want something specific
  location = "West US 2" # Change the location here if you want use another region

  tags = {
    created_by = "Terraform"
  }
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = "${random_pet.prefix.id}-aks" # Change the name here if you want something specific
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "${random_pet.prefix.id}-k8s" # Change the DNS prefix here if you want something specific

  default_node_pool {
    name            = "default"
    node_count      = 2 # How many nodes do you want in your cluster?
    vm_size         = "Standard_B2s" # Change the size of the VM running the node
    os_disk_size_gb = 30 # Change the OS disk size (GB) on each node
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  role_based_access_control {
    enabled = true
  }

  tags = {
    created_by = "Terraform"
  }
}
