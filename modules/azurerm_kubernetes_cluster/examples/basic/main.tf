# Basic AKS Cluster Example
# This example creates a minimal AKS cluster with secure defaults

terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.43.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Create a virtual network for the cluster
resource "azurerm_virtual_network" "example" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

# Create a subnet for the AKS nodes
resource "azurerm_subnet" "example" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create the AKS cluster
module "kubernetes_cluster" {
  source = "../../"

  # Basic cluster configuration
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # DNS configuration
  dns_config = {
    dns_prefix = var.dns_prefix
  }

  # Use system-assigned managed identity (secure default)
  identity = {
    type         = "SystemAssigned"
    identity_ids = null
  }

  # Default node pool with minimal configuration
  default_node_pool = {
    name                 = "default"
    vm_size              = "Standard_D2s_v3"
    node_count           = 2
    auto_scaling_enabled = false
    vnet_subnet_id       = azurerm_subnet.example.id
    os_disk_type         = "Managed"
    os_sku               = "Ubuntu"
    upgrade_settings = {
      max_surge = "33%"
    }
  }

  # Basic network profile
  network_profile = {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr   = "172.16.0.0/16" # Non-overlapping with VNet CIDR
    dns_service_ip = "172.16.0.10"   # Must be within service_cidr
  }


  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
