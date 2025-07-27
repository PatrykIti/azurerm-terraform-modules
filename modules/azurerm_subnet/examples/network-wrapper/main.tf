# Network Wrapper Example
# This example demonstrates how to manage subnet associations at the wrapper level
# for maximum flexibility and reusability

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.36.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "rg-subnet-wrapper-${var.name_suffix}"
  location = var.location

  tags = var.tags
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "vnet-wrapper-${var.name_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]

  tags = var.tags
}

# Network Security Groups
resource "azurerm_network_security_group" "app" {
  name                = "nsg-app-${var.name_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_network_security_group" "data" {
  name                = "nsg-data-${var.name_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  # More restrictive rules for data tier
  security_rule {
    name                       = "AllowAppTier"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "10.0.1.0/24" # App subnet
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Route Tables
resource "azurerm_route_table" "app" {
  name                          = "rt-app-${var.name_suffix}"
  location                      = azurerm_resource_group.example.location
  resource_group_name           = azurerm_resource_group.example.name
  disable_bgp_route_propagation = false

  route {
    name           = "ToInternet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  tags = var.tags
}

resource "azurerm_route_table" "data" {
  name                          = "rt-data-${var.name_suffix}"
  location                      = azurerm_resource_group.example.location
  resource_group_name           = azurerm_resource_group.example.name
  disable_bgp_route_propagation = true

  # Force all traffic through firewall
  route {
    name                   = "ToFirewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.250.4" # Firewall IP
  }

  tags = var.tags
}

# Subnets using the module
module "subnet_app" {
  source = "../../"

  name                 = "subnet-app-${var.name_suffix}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.KeyVault"
  ]

  tags = merge(var.tags, {
    Tier = "Application"
  })
}

module "subnet_data" {
  source = "../../"

  name                 = "subnet-data-${var.name_suffix}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]

  service_endpoints = [
    "Microsoft.Sql",
    "Microsoft.Storage"
  ]

  tags = merge(var.tags, {
    Tier = "Data"
  })
}

module "subnet_management" {
  source = "../../"

  name                 = "subnet-mgmt-${var.name_suffix}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.3.0/24"]

  # No service endpoints for management subnet
  service_endpoints = []

  tags = merge(var.tags, {
    Tier = "Management"
  })
}

# Network Security Group Associations - managed at wrapper level
resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = module.subnet_app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

resource "azurerm_subnet_network_security_group_association" "data" {
  subnet_id                 = module.subnet_data.id
  network_security_group_id = azurerm_network_security_group.data.id
}

# Management subnet uses the app NSG
resource "azurerm_subnet_network_security_group_association" "management" {
  subnet_id                 = module.subnet_management.id
  network_security_group_id = azurerm_network_security_group.app.id
}

# Route Table Associations - managed at wrapper level
resource "azurerm_subnet_route_table_association" "app" {
  subnet_id      = module.subnet_app.id
  route_table_id = azurerm_route_table.app.id
}

resource "azurerm_subnet_route_table_association" "data" {
  subnet_id      = module.subnet_data.id
  route_table_id = azurerm_route_table.data.id
}

# Management subnet doesn't need custom routing

# This pattern provides maximum flexibility:
# 1. Subnets can be created independently
# 2. NSGs and Route Tables can be shared or unique per subnet
# 3. Associations can be added/removed without modifying subnet configuration
# 4. Different environments can use different security configurations