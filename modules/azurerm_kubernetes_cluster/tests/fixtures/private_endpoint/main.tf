terraform {
  required_version = ">= 1.11.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.36.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-dpc-pe-${var.random_suffix}"
  location = var.location
}

resource "azurerm_virtual_network" "aks" {
  name                = "vnet-dpc-pe-${var.random_suffix}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "aks_nodes" {
  name                 = "snet-dpc-pe-nodes-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "private_endpoints" {
  name                              = "snet-dpc-pe-endpoints-${var.random_suffix}"
  resource_group_name               = azurerm_resource_group.test.name
  virtual_network_name              = azurerm_virtual_network.aks.name
  address_prefixes                  = ["10.0.2.0/24"]
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_private_dns_zone" "aks" {
  name                = "privatelink.${var.location}.azmk8s.io"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "aks" {
  name                  = "dns-link-dpc-pe-${var.random_suffix}"
  resource_group_name   = azurerm_resource_group.test.name
  private_dns_zone_name = azurerm_private_dns_zone.aks.name
  virtual_network_id    = azurerm_virtual_network.aks.id
}

# Create user-assigned identity for AKS
resource "azurerm_user_assigned_identity" "aks" {
  name                = "uai-dpc-pe-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

# Grant the identity permissions to the private DNS zone
resource "azurerm_role_assignment" "dns_contributor" {
  scope                = azurerm_private_dns_zone.aks.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

# Grant the identity permissions to the virtual network
resource "azurerm_role_assignment" "network_contributor" {
  scope                = azurerm_virtual_network.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

module "kubernetes_cluster" {
  source = "../../.."

  name                = "aks-dpc-pe-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  dns_config = {
    dns_prefix_private_cluster = "aksdpcpe${var.random_suffix}"
  }

  kubernetes_config = {
    kubernetes_version = var.kubernetes_version
  }

  default_node_pool = {
    name           = "system"
    vm_size        = "Standard_D2s_v3"
    vnet_subnet_id = azurerm_subnet.aks_nodes.id
    node_count     = 1
  }

  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  network_profile = {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "10.100.0.0/16"
    dns_service_ip    = "10.100.0.10"
  }

  private_cluster_config = {
    private_cluster_enabled = true
    private_dns_zone_id     = azurerm_private_dns_zone.aks.id
  }

  private_endpoints = [
    {
      name      = "pe-dpc-pe-${var.random_suffix}"
      subnet_id = azurerm_subnet.private_endpoints.id
      private_dns_zone_group = {
        name                 = "default"
        private_dns_zone_ids = [azurerm_private_dns_zone.aks.id]
      }
    }
  ]

  tags = var.tags

  depends_on = [
    azurerm_role_assignment.dns_contributor,
    azurerm_role_assignment.network_contributor
  ]
}

# Add delay to help with cleanup of private AKS resources
resource "time_sleep" "wait_for_aks_cleanup" {
  depends_on = [module.kubernetes_cluster]

  destroy_duration = "180s" # Wait 3 minutes on destroy to allow Azure to clean up managed resources
}

# Ensure proper cleanup order
resource "null_resource" "subnet_cleanup_dependency" {
  depends_on = [
    module.kubernetes_cluster,
    time_sleep.wait_for_aks_cleanup
  ]

  triggers = {
    subnet_id = azurerm_subnet.aks_nodes.id
  }
}

resource "null_resource" "vnet_cleanup_dependency" {
  depends_on = [
    module.kubernetes_cluster,
    time_sleep.wait_for_aks_cleanup,
    null_resource.subnet_cleanup_dependency
  ]

  triggers = {
    vnet_id = azurerm_virtual_network.aks.id
  }
}