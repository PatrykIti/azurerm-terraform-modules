# Multi Node Pool AKS Cluster Example
# This example creates an AKS cluster with multiple node pools for cost-effective testing

terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
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

# Create the AKS cluster with multiple node pools
module "kubernetes_cluster" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_kubernetes_cluster?ref=AKSv1.0.0"

  # Basic cluster configuration
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # DNS configuration
  dns_config = {
    dns_prefix = var.dns_prefix
  }

  # Use system-assigned managed identity
  identity = {
    type         = "SystemAssigned"
    identity_ids = null
  }

  # System node pool - minimal configuration for cost savings
  default_node_pool = {
    name                 = "system"
    vm_size              = "Standard_D2s_v3"
    node_count           = 2
    auto_scaling_enabled = false
    vnet_subnet_id       = azurerm_subnet.example.id
    os_disk_type         = "Managed"
    os_sku               = "Ubuntu"
    mode                 = "System" # Explicitly set as system pool
    upgrade_settings = {
      max_surge = "33%"
    }
  }

  # Additional node pools
  node_pools = [
    {
      # User pool for general workloads
      name                 = "userpool"
      vm_size              = "Standard_D2s_v3"
      node_count           = 1 # Minimal nodes for cost savings
      auto_scaling_enabled = false
      vnet_subnet_id       = azurerm_subnet.example.id
      os_disk_type         = "Managed"
      os_sku               = "Ubuntu"
      mode                 = "User"
      priority             = "Regular" # No spot instances for reliability
      node_labels = {
        "workload-type" = "general"
        "pool-type"     = "user"
      }
      node_taints = [] # No taints for general workloads
    }
  ]

  # Basic network profile
  network_profile = {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr   = "172.16.0.0/16"
    dns_service_ip = "172.16.0.10"
  }

  # Keep costs low with minimal features
  features = {
    azure_policy_enabled             = false
    http_application_routing_enabled = false
    workload_identity_enabled        = false
    oidc_issuer_enabled              = false
    open_service_mesh_enabled        = false
    image_cleaner_enabled            = false
    run_command_enabled              = true
    local_account_disabled           = false
    cost_analysis_enabled            = false
  }

  # Free tier for cost savings
  sku_config = {
    sku_tier     = "Free"
    support_plan = "KubernetesOfficial"
  }

  tags = {
    Environment = "Development"
    Example     = "MultiNodePool"
    CostProfile = "Minimal"
  }
}
