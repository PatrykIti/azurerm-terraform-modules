provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "rg-aks-negative-${var.random_suffix}"
  location = var.location
}

module "kubernetes_cluster" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv2.1.0"

  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  dns_config = {
    dns_prefix = "aksinvalid"
  }

  default_node_pool = {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity = {
    type = "SystemAssigned"
  }
}
