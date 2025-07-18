provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-aks-negative-${var.random_suffix}"
  location = var.location
}

module "kubernetes_cluster" {
  source = "../../.."

  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  dns_prefix          = "aksinvalid"

  default_node_pool = {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity = {
    type = "SystemAssigned"
  }
}
