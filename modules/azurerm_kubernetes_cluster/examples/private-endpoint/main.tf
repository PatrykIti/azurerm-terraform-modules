provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-aks-private-endpoint-example"
  location = "West Europe"
}

# Virtual Network for AKS
resource "azurerm_virtual_network" "aks" {
  name                = "vnet-aks-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet for AKS nodes
resource "azurerm_subnet" "aks_nodes" {
  name                 = "subnet-aks-nodes"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Virtual Network for DevOps VNet
resource "azurerm_virtual_network" "devops" {
  name                = "vnet-devops-example"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet for DevOps private endpoint
resource "azurerm_subnet" "devops_endpoint" {
  name                                      = "subnet-devops-endpoint"
  resource_group_name                       = azurerm_resource_group.example.name
  virtual_network_name                      = azurerm_virtual_network.devops.name
  address_prefixes                          = ["10.1.1.0/24"]
  private_endpoint_network_policies = "Disabled"
}

# Virtual Network for Jumpbox VNet
resource "azurerm_virtual_network" "jumpbox" {
  name                = "vnet-jumpbox-example"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet for Jumpbox private endpoint
resource "azurerm_subnet" "jumpbox_endpoint" {
  name                                      = "subnet-jumpbox-endpoint"
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

module "kubernetes_cluster" {
  source = "../../"

  name                = "aks-private-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # DNS configuration for private cluster
  dns_config = {
    dns_prefix_private_cluster = "aks-private-example"
  }

  # Kubernetes configuration
  kubernetes_config = {
    kubernetes_version        = "1.27.9"
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

  # Identity configuration
  identity = {
    type = "SystemAssigned"
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
}
