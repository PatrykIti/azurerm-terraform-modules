provider "azurerm" {
  features {}
}

resource "random_id" "test" {
  byte_length = 4
}

resource "azurerm_resource_group" "test" {
  name     = "rg-aks-test-${random_id.test.hex}"
  location = var.location
}

# Virtual Network for AKS
resource "azurerm_virtual_network" "aks" {
  name                = "vnet-aks-test-${random_id.test.hex}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

# Subnet for AKS nodes
resource "azurerm_subnet" "aks_nodes" {
  name                 = "subnet-aks-nodes"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Subnet for private endpoints
resource "azurerm_subnet" "private_endpoints" {
  name                              = "subnet-private-endpoints"
  resource_group_name               = azurerm_resource_group.test.name
  virtual_network_name              = azurerm_virtual_network.aks.name
  address_prefixes                  = ["10.0.2.0/24"]
  private_endpoint_network_policies = "Disabled"
}

# Private DNS Zone
resource "azurerm_private_dns_zone" "aks" {
  name                = "privatelink.${var.location}.azmk8s.io"
  resource_group_name = azurerm_resource_group.test.name
}

# Link DNS zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "aks" {
  name                  = "dns-link-aks"
  resource_group_name   = azurerm_resource_group.test.name
  private_dns_zone_name = azurerm_private_dns_zone.aks.name
  virtual_network_id    = azurerm_virtual_network.aks.id
}

module "kubernetes_cluster" {
  source = "../../../"

  name                = "aks-test-${random_id.test.hex}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  # DNS configuration for private cluster
  dns_config = {
    dns_prefix_private_cluster = "aks-test-${random_id.test.hex}"
  }

  # Kubernetes configuration
  kubernetes_config = {
    kubernetes_version = var.kubernetes_version
  }

  # Default node pool configuration
  default_node_pool = {
    name                 = "system"
    vm_size              = "Standard_D2s_v3"
    vnet_subnet_id       = azurerm_subnet.aks_nodes.id
    node_count           = 1
    auto_scaling_enabled = false
    upgrade_settings = {
      max_surge = "33%"
    }
  }

  # Identity configuration
  identity = {
    type = "SystemAssigned"
  }

  # Network configuration
  network_profile = {
    network_plugin    = "azure"
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
      name      = "pe-aks-test-1"
      subnet_id = azurerm_subnet.private_endpoints.id
      private_dns_zone_group = {
        name                 = "default"
        private_dns_zone_ids = [azurerm_private_dns_zone.aks.id]
      }
    },
    {
      name      = "pe-aks-test-2"
      subnet_id = azurerm_subnet.private_endpoints.id
      # No DNS group - testing both scenarios
    }
  ]

  tags = var.tags
}
