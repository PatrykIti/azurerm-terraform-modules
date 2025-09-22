# Network integration test fixture
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-dpc-net-${var.random_suffix}"
  location = var.location
}

resource "azurerm_virtual_network" "test" {
  name                = "vnet-dpc-net-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "snet-dpc-net-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Test with network configuration
module "kubernetes_cluster" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_subnet?ref=SNv1.0.4"

  name                = "aks-dpc-net-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  dns_config = {
    dns_prefix = "aks-dpc-net-${var.random_suffix}"
  }

  identity = {
    type = "SystemAssigned"
  }

  default_node_pool = {
    name           = "default"
    vm_size        = "Standard_D2s_v3"
    node_count     = 1
    vnet_subnet_id = azurerm_subnet.test.id
  }

  network_profile = {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr   = "172.16.0.0/16"
    dns_service_ip = "172.16.0.10"
  }

  tags = {
    Environment = "Test"
    Scenario    = "Network"
  }
}