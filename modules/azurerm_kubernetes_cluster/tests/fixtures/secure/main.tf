provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-dpc-sec-${var.random_suffix}"
  location = var.location
}

resource "azurerm_virtual_network" "test" {
  name                = "vnet-dpc-sec-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "snet-dpc-sec-${var.random_suffix}"
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

  name                = "aks-dpc-sec-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  dns_config = {
    dns_prefix_private_cluster = "aksdpcsec${var.random_suffix}"
  }

  default_node_pool = {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.test.id
  }

  identity = {
    type = "SystemAssigned"
  }

  private_cluster_config = {
    private_cluster_enabled = true
    private_dns_zone_id     = azurerm_private_dns_zone.test.id
  }

  features = {
    azure_policy_enabled = true
  }

  tags = {
    Environment = "Test"
    Example     = "Secure"
  }
}