provider "azurerm" {
  features {}
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "test" {
  name     = "rg-aks-secure-${random_string.suffix.result}"
  location = var.location
}

resource "azurerm_virtual_network" "test" {
  name                = "vnet-aks-secure-${random_string.suffix.result}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "snet-aks-nodes-${random_string.suffix.result}"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_private_dns_zone" "test" {
  name                = "privatelink.${var.location}.azmk8s.io"
  resource_group_name = azurerm_resource_group.test.name
}

module "kubernetes_cluster" {
  source = "../../.."

  name                = "aks-secure-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  dns_prefix          = "akssecure${random_string.suffix.result}"

  default_node_pool = {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.test.id
  }

  identity = {
    type = "SystemAssigned"
  }

  private_cluster_enabled = true
  private_dns_zone_id     = azurerm_private_dns_zone.test.id

  addon_profiles = {
    azure_policy = {
      enabled = true
    }
  }

  tags = {
    Environment = "Test"
    Example     = "Secure"
  }
}