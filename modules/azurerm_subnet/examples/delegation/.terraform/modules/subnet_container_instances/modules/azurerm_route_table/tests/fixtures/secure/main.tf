# Secure Route Table Example
# This example demonstrates security-focused route table configuration

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
  name     = "rg-rt-sec-${var.random_suffix}"
  location = var.location
}

# Create a virtual network for secure routing
resource "azurerm_virtual_network" "test" {
  name                = "vnet-rt-sec-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

# Create DMZ subnet
resource "azurerm_subnet" "dmz" {
  name                 = "snet-dmz-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create application subnet
resource "azurerm_subnet" "app" {
  name                 = "snet-app-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create database subnet
resource "azurerm_subnet" "db" {
  name                 = "snet-db-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.3.0/24"]
}

# Create security appliance subnet
resource "azurerm_subnet" "security" {
  name                 = "snet-security-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.100.0/24"]
}

# Create network interface for security appliance (firewall/IDS)
resource "azurerm_network_interface" "security_appliance" {
  name                  = "nic-secapp-${var.random_suffix}"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.security.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.100.4"
  }
}

# Create the secure route table
module "route_table" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_subnet?ref=SNv1.0.4"

  # Route table configuration
  name                = "rt-sec-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  # Disable BGP route propagation for maximum control
  bgp_route_propagation_enabled = false

  # Define security-focused routes
  routes = [
    # Force all internet traffic through security appliance
    {
      name                   = "route-internet-via-firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.100.4"
    },
    # Force DMZ traffic through security appliance
    {
      name                   = "route-dmz-via-firewall"
      address_prefix         = "10.0.1.0/24"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.100.4"
    },
    # Block direct database access from internet
    {
      name                   = "route-block-db-internet"
      address_prefix         = "10.0.3.0/24"
      next_hop_type          = "None"
      next_hop_in_ip_address = null
    },
    # Force VPN traffic through security appliance
    {
      name                   = "route-vpn-via-firewall"
      address_prefix         = "172.16.0.0/12"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.100.4"
    },
    # Block RFC1918 private ranges by default
    {
      name                   = "route-block-rfc1918-a"
      address_prefix         = "192.168.0.0/16"
      next_hop_type          = "None"
      next_hop_in_ip_address = null
    },
    # Allow local VNet traffic
    {
      name                   = "route-allow-local-vnet"
      address_prefix         = "10.0.0.0/16"
      next_hop_type          = "VnetLocal"
      next_hop_in_ip_address = null
    }
  ]

  tags = {
    Environment    = "Production"
    Example        = "Secure"
    SecurityLevel  = "High"
    ComplianceType = "PCI-DSS"
    DataClass      = "Confidential"
    ManagedBy      = "Terraform"
  }
}

# Associate route table with application subnet for secure routing
resource "azurerm_subnet_route_table_association" "app" {
  subnet_id      = azurerm_subnet.app.id
  route_table_id = module.route_table.id
}

# Associate route table with database subnet for secure routing
resource "azurerm_subnet_route_table_association" "db" {
  subnet_id      = azurerm_subnet.db.id
  route_table_id = module.route_table.id
}
