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
  name     = "rg-dpc-cmp-${var.random_suffix}"
  location = var.location
}

# Create Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "test" {
  name                = "law-dpc-cmp-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Create virtual network
resource "azurerm_virtual_network" "test" {
  name                = "vnet-dpc-cmp-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

# Create subnet for AKS nodes
resource "azurerm_subnet" "test" {
  name                 = "snet-dpc-cmp-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create Private DNS Zone for the private cluster
resource "azurerm_private_dns_zone" "test" {
  name                = "privatelink.${var.location}.azmk8s.io"
  resource_group_name = azurerm_resource_group.test.name
}

# Create user-assigned identity for AKS
resource "azurerm_user_assigned_identity" "test" {
  name                = "uai-dpc-cmp-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

# Grant the identity permissions to the private DNS zone
resource "azurerm_role_assignment" "dns_contributor" {
  scope                = azurerm_private_dns_zone.test.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

# Create the AKS cluster with comprehensive configuration
module "kubernetes_cluster" {
  source = "../../.."

  # Core configuration
  name                = "aks-dpc-cmp-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  # DNS configuration
  dns_config = {
    dns_prefix_private_cluster = "aksdpccmp${var.random_suffix}"
  }

  kubernetes_config = {
    kubernetes_version = "1.30.5"
  }

  # Identity configuration
  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
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

  # Network configuration for private cluster
  network_profile = {
    service_cidr   = "172.16.0.0/16"
    dns_service_ip = "172.16.0.10"
  }

  features = {
    azure_policy_enabled = true
  }

  tags = {
    Environment = "Test"
    Example     = "Complete"
  }
  
  depends_on = [azurerm_role_assignment.dns_contributor]
}