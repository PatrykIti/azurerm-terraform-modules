provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-aks-complete-${var.random_suffix}"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "law-aks-complete-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_virtual_network" "test" {
  name                = "vnet-aks-complete-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "snet-aks-nodes-${var.random_suffix}"
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

  name                = "aks-complete-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  dns_prefix          = "akscomplete${var.random_suffix}"
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
    authorized_ip_ranges = ["0.0.0.0/32"]
  }

  private_cluster_enabled = true
  private_dns_zone_id     = azurerm_private_dns_zone.test.id

  addon_profiles = {
    azure_policy = {
      enabled = true
    }
    oms_agent = {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
    }
  }

  tags = {
    Environment = "Test"
    Example     = "Complete"
  }
}