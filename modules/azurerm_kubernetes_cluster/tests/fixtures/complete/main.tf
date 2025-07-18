# Complete AKS Cluster Example
# This example demonstrates a comprehensive AKS cluster configuration with advanced features

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "test" {
  name     = "rg-aks-complete-${var.random_suffix}"
  location = var.location
}

# Create Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "test" {
  name                = "law-aks-complete-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Create virtual network
resource "azurerm_virtual_network" "test" {
  name                = "vnet-aks-complete-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

# Create subnet for AKS nodes
resource "azurerm_subnet" "test" {
  name                 = "snet-aks-nodes-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create Private DNS Zone for the private cluster
resource "azurerm_private_dns_zone" "test" {
  name                = "privatelink.${var.location}.azmk8s.io"
  resource_group_name = azurerm_resource_group.test.name
}

# Create the AKS cluster with comprehensive configuration
module "kubernetes_cluster" {
  source = "../../.."

  # Core configuration
  name                = "aks-complete-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  # DNS configuration
  dns_config = {
    dns_prefix_private_cluster = "akscomplete${var.random_suffix}"
  }

  kubernetes_config = {
    kubernetes_version = "1.28.5"
  }

  # Identity configuration
  identity = {
    type = "SystemAssigned"
  }

  # Default node pool
  default_node_pool = {
    name           = "default"
    node_count     = 2
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.test.id
  }

  # Private cluster configuration
  private_cluster_config = {
    private_cluster_enabled = true
    private_dns_zone_id     = azurerm_private_dns_zone.test.id
  }

  # Enable addons
  oms_agent = {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  }

  features = {
    azure_policy_enabled = true
  }

  # Restrict API server access
  api_server_access_profile = {
    authorized_ip_ranges = ["0.0.0.0/32"]
  }

  tags = {
    Environment = "Test"
    Example     = "Complete"
  }
}