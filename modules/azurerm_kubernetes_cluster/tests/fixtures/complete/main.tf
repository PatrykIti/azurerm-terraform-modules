provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-aks-cmp-${var.random_suffix}"
  location = var.location
}

resource "azurerm_virtual_network" "test" {
  name                = "vnet-aks-cmp-${var.random_suffix}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "snet-aks-cmp"
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

  name                = "aks-cmp-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  dns_prefix          = "akscmp${var.random_suffix}"
  kubernetes_version  = "1.28.5"

  default_node_pool = {
    name           = "default"
    node_count     = 2
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.test.id
  }

  identity = {
    type = "SystemAssigned"
  }

  api_server_access_profile = {
    authorized_ip_ranges = ["192.168.0.0/16"]
  }

  private_cluster_enabled = true
  private_dns_zone_id     = azurerm_private_dns_zone.test.id

  addon_profiles = {
    azure_policy = {
      enabled = true
    }
    oms_agent = {
      enabled                    = true
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  tags = {
    Environment = "Test"
    Example     = "Complete"
  }
}