provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "default" {
  name     = "${var.PROJECT_NAME}-k8s-rg-${var.ENVIRONMENT}"
  location = var.CLOUD_LOCATION

  tags = {
    created_by = "Terraform"
  }
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = "${var.PROJECT_NAME}-k8s-aks-${var.ENVIRONMENT}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "${var.PROJECT_NAME}-k8s-${var.ENVIRONMENT}"

  default_node_pool {
    name            = "default"
    node_count      = var.NODE_COUNT
    vm_size         = var.VM_SIZE
    os_disk_size_gb = var.NODE_DISK_SIZE_GB
  }

  service_principal {
    client_id     = var.CLIENT_ID
    client_secret = var.CLIENT_SECRET
  }

  role_based_access_control {
    enabled = true
  }

  tags = {
    created_by = "Terraform"
  }
}
