provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-aks-smp-${var.random_suffix}"
  location = var.location
}

resource "azurerm_virtual_network" "test" {
  name                = "vnet-aks-smp-${var.random_suffix}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "snet-aks-smp"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "kubernetes_cluster" {
  source = "../../.."

  name                = "aks-smp-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  dns_prefix          = "akssmp${var.random_suffix}"

  default_node_pool = {
    name           = "default"
    node_count     = var.node_count
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.test.id
  }

  identity = {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Test"
    Example     = "Basic"
  }
}