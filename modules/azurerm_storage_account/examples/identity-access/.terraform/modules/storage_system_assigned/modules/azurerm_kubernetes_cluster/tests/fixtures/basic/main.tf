# Basic AKS Cluster Example
# This example creates a minimal AKS cluster with secure defaults

terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.57.0"
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
resource "azurerm_resource_group" "test" {
  name     = "rg-dpc-bas-${var.random_suffix}"
  location = var.location
}

# Create a virtual network for the cluster
resource "azurerm_virtual_network" "test" {
  name                = "vnet-dpc-bas-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

# Create a subnet for the AKS nodes
resource "azurerm_subnet" "test" {
  name                 = "snet-dpc-bas-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create the AKS cluster
module "kubernetes_cluster" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv2.1.0"

  # Basic cluster configuration
  name                = "aks-dpc-bas-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  # DNS configuration
  dns_config = {
    dns_prefix = "aks-dpc-bas-${var.random_suffix}"
  }

  # Use system-assigned managed identity (secure default)
  identity = {
    type = "SystemAssigned"
  }

  # Default node pool with minimal configuration
  default_node_pool = {
    name           = "default"
    vm_size        = "Standard_D2_v2"
    node_count     = var.node_count
    vnet_subnet_id = azurerm_subnet.test.id
  }

  # Basic network profile
  network_profile = {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr   = "172.16.0.0/16"
    dns_service_ip = "172.16.0.10"
  }

  tags = {
    Environment = "Test"
    Example     = "Basic"
  }
}
