terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.36.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
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

# Generate random suffix for unique naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "example" {
  name     = "rg-aks-private-endpoint-${random_string.suffix.result}"
  location = "West Europe"
}

# Create Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-aks-private-endpoint-${random_string.suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Virtual Network for AKS
resource "azurerm_virtual_network" "aks" {
  name                = "vnet-aks-private-endpoint-${random_string.suffix.result}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet for AKS nodes
resource "azurerm_subnet" "aks_nodes" {
  name                 = "snet-aks-nodes-${random_string.suffix.result}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create Network Security Group for nodes
resource "azurerm_network_security_group" "example" {
  name                = "nsg-aks-nodes-${random_string.suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Associate NSG with node subnet
resource "azurerm_subnet_network_security_group_association" "nodes" {
  subnet_id                 = azurerm_subnet.aks_nodes.id
  network_security_group_id = azurerm_network_security_group.example.id
}

# Virtual Network for DevOps VNet
resource "azurerm_virtual_network" "devops" {
  name                = "vnet-devops-${random_string.suffix.result}"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet for DevOps private endpoint
resource "azurerm_subnet" "devops_endpoint" {
  name                                      = "snet-devops-endpoint-${random_string.suffix.result}"
  resource_group_name                       = azurerm_resource_group.example.name
  virtual_network_name                      = azurerm_virtual_network.devops.name
  address_prefixes                          = ["10.1.1.0/24"]
  private_endpoint_network_policies = "Disabled"
}

# Virtual Network for Jumpbox VNet
resource "azurerm_virtual_network" "jumpbox" {
  name                = "vnet-jumpbox-${random_string.suffix.result}"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet for Jumpbox private endpoint
resource "azurerm_subnet" "jumpbox_endpoint" {
  name                                      = "snet-jumpbox-endpoint-${random_string.suffix.result}"
  resource_group_name                       = azurerm_resource_group.example.name
  virtual_network_name                      = azurerm_virtual_network.jumpbox.name
  address_prefixes                          = ["10.2.1.0/24"]
  private_endpoint_network_policies = "Disabled"
}

# Private DNS Zone (managed separately as per the pattern)
resource "azurerm_private_dns_zone" "aks" {
  name                = "privatelink.westeurope.azmk8s.io"
  resource_group_name = azurerm_resource_group.example.name
}

# Link DNS zone to VNets
resource "azurerm_private_dns_zone_virtual_network_link" "devops" {
  name                  = "dns-link-devops"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.aks.name
  virtual_network_id    = azurerm_virtual_network.devops.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "jumpbox" {
  name                  = "dns-link-jumpbox"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.aks.name
  virtual_network_id    = azurerm_virtual_network.jumpbox.id
}

# User-assigned identity for AKS (required for custom private DNS zone)
resource "azurerm_user_assigned_identity" "aks" {
  name                = "uai-aks-private-endpoint-${random_string.suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Grant the user-assigned identity permissions to the private DNS zone
resource "azurerm_role_assignment" "aks_dns_contributor" {
  scope                = azurerm_private_dns_zone.aks.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

# Grant the user-assigned identity Network Contributor role on the AKS VNet
# This is required for AKS to manage DNS zone links
resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = azurerm_virtual_network.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

module "kubernetes_cluster" {
  source = "../../"

  name                = "aks-private-endpoint-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # DNS configuration for private cluster
  dns_config = {
    dns_prefix_private_cluster = "aks-private-endpoint-${random_string.suffix.result}"
  }

  # Kubernetes configuration
  kubernetes_config = {
    kubernetes_version        = "1.30"
    automatic_upgrade_channel = "stable"
  }

  # SKU configuration
  sku_config = {
    sku_tier = "Standard"
  }

  # Default node pool configuration
  default_node_pool = {
    name                 = "system"
    vm_size              = "Standard_D2s_v3"
    vnet_subnet_id       = azurerm_subnet.aks_nodes.id
    auto_scaling_enabled = true
    min_count            = 1
    max_count            = 3
    node_count           = 1
    upgrade_settings = {
      max_surge = "33%"
    }
  }

  # Identity configuration (user-assigned required for custom private DNS zone)
  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  # Network configuration
  network_profile = {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "10.100.0.0/16"
    dns_service_ip    = "10.100.0.10"
  }

  # Private cluster configuration
  private_cluster_config = {
    private_cluster_enabled             = true
    private_dns_zone_id                 = azurerm_private_dns_zone.aks.id
    private_cluster_public_fqdn_enabled = false
  }

  # Private endpoints configuration
  private_endpoints = [
    {
      name      = "pe-aks-prod-devops"
      subnet_id = azurerm_subnet.devops_endpoint.id
      private_dns_zone_group = {
        name                 = "default"
        private_dns_zone_ids = [azurerm_private_dns_zone.aks.id]
      }
    },
    {
      name      = "pe-aks-prod-jumpbox"
      subnet_id = azurerm_subnet.jumpbox_endpoint.id
      # No DNS group - can be managed externally
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Private-Endpoint"
  }

  # Ensure role assignments are completed before creating AKS
  depends_on = [
    azurerm_role_assignment.aks_dns_contributor,
    azurerm_role_assignment.aks_network_contributor
  ]
}
