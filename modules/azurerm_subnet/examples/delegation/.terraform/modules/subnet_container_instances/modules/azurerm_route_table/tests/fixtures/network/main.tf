# Network Route Table Example
# This example demonstrates complex network routing scenarios with multiple VNets and peering

terraform {
  required_version = ">= 1.11.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.43.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "test" {
  name     = "rg-rt-net-${var.random_suffix}"
  location = var.location
}

# Create hub virtual network
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

# Create spoke 1 virtual network
resource "azurerm_virtual_network" "spoke1" {
  name                = "vnet-spoke1-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.1.0.0/16"]
}

# Create spoke 2 virtual network
resource "azurerm_virtual_network" "spoke2" {
  name                = "vnet-spoke2-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.2.0.0/16"]
}

# Hub subnets
resource "azurerm_subnet" "hub_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "hub_firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "hub_shared" {
  name                 = "snet-shared-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.3.0/24"]
}

# Spoke 1 subnets
resource "azurerm_subnet" "spoke1_workload" {
  name                 = "snet-workload-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.spoke1.name
  address_prefixes     = ["10.1.1.0/24"]
}

# Spoke 2 subnets
resource "azurerm_subnet" "spoke2_workload" {
  name                 = "snet-workload-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.spoke2.name
  address_prefixes     = ["10.2.1.0/24"]
}

# Create network interface for NVA in hub
resource "azurerm_network_interface" "hub_nva" {
  name                  = "nic-hub-nva-${var.random_suffix}"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub_shared.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.3.4"
  }
}

# VNet peering - Hub to Spoke1
resource "azurerm_virtual_network_peering" "hub_to_spoke1" {
  name                      = "hub-to-spoke1"
  resource_group_name       = azurerm_resource_group.test.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke1.id
  allow_gateway_transit     = true
  allow_forwarded_traffic   = true

  depends_on = [
    azurerm_subnet.hub_gateway,
    azurerm_subnet.hub_firewall,
    azurerm_subnet.hub_shared
  ]
}

resource "azurerm_virtual_network_peering" "spoke1_to_hub" {
  name                      = "spoke1-to-hub"
  resource_group_name       = azurerm_resource_group.test.name
  virtual_network_name      = azurerm_virtual_network.spoke1.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  use_remote_gateways       = false # Set to true when gateway is deployed
  allow_forwarded_traffic   = true

  depends_on = [
    azurerm_subnet.spoke1_workload,
    azurerm_virtual_network_peering.hub_to_spoke1
  ]
}

# VNet peering - Hub to Spoke2
resource "azurerm_virtual_network_peering" "hub_to_spoke2" {
  name                      = "hub-to-spoke2"
  resource_group_name       = azurerm_resource_group.test.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke2.id
  allow_gateway_transit     = true
  allow_forwarded_traffic   = true

  depends_on = [
    azurerm_subnet.hub_gateway,
    azurerm_subnet.hub_firewall,
    azurerm_subnet.hub_shared
  ]
}

resource "azurerm_virtual_network_peering" "spoke2_to_hub" {
  name                      = "spoke2-to-hub"
  resource_group_name       = azurerm_resource_group.test.name
  virtual_network_name      = azurerm_virtual_network.spoke2.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  use_remote_gateways       = false # Set to true when gateway is deployed
  allow_forwarded_traffic   = true

  depends_on = [
    azurerm_subnet.spoke2_workload,
    azurerm_virtual_network_peering.hub_to_spoke2
  ]
}

# Hub route table
module "hub_route_table" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_subnet?ref=SNv1.0.4"

  name                = "rt-hub-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  bgp_route_propagation_enabled = true

  routes = [
    # Route spoke1 traffic to NVA
    {
      name                   = "route-to-spoke1"
      address_prefix         = "10.1.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.3.4"
    },
    # Route spoke2 traffic to NVA
    {
      name                   = "route-to-spoke2"
      address_prefix         = "10.2.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.3.4"
    }
  ]

  tags = {
    Environment = "Test"
    Example     = "Network"
    Tier        = "Hub"
  }
}

# Spoke1 route table
module "spoke1_route_table" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_subnet?ref=SNv1.0.4"

  name                = "rt-spoke1-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  bgp_route_propagation_enabled = false

  routes = [
    # Default route to hub NVA
    {
      name                   = "route-default"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.3.4"
    },
    # Route to spoke2 via hub NVA
    {
      name                   = "route-to-spoke2"
      address_prefix         = "10.2.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.3.4"
    },
    # Route to on-premises via VPN gateway
    {
      name                   = "route-to-onprem"
      address_prefix         = "192.168.0.0/16"
      next_hop_type          = "VirtualNetworkGateway"
      next_hop_in_ip_address = null
    }
  ]

  tags = {
    Environment = "Test"
    Example     = "Network"
    Tier        = "Spoke1"
  }
}

# Spoke2 route table
module "spoke2_route_table" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_subnet?ref=SNv1.0.4"

  name                = "rt-spoke2-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  bgp_route_propagation_enabled = false

  routes = [
    # Default route to hub NVA
    {
      name                   = "route-default"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.3.4"
    },
    # Route to spoke1 via hub NVA
    {
      name                   = "route-to-spoke1"
      address_prefix         = "10.1.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.3.4"
    },
    # Route to on-premises via VPN gateway
    {
      name                   = "route-to-onprem"
      address_prefix         = "192.168.0.0/16"
      next_hop_type          = "VirtualNetworkGateway"
      next_hop_in_ip_address = null
    }
  ]

  tags = {
    Environment = "Test"
    Example     = "Network"
    Tier        = "Spoke2"
  }
}

# Associate route tables with subnets
resource "azurerm_subnet_route_table_association" "hub_shared" {
  subnet_id      = azurerm_subnet.hub_shared.id
  route_table_id = module.hub_route_table.id
}

resource "azurerm_subnet_route_table_association" "spoke1_workload" {
  subnet_id      = azurerm_subnet.spoke1_workload.id
  route_table_id = module.spoke1_route_table.id
}

resource "azurerm_subnet_route_table_association" "spoke2_workload" {
  subnet_id      = azurerm_subnet.spoke2_workload.id
  route_table_id = module.spoke2_route_table.id
}