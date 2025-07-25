terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.85.0, < 4.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "df86479f-16c4-4326-984c-14929d7899e3"
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = var.virtual_network_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = var.tags
}

# Network Security Group
resource "azurerm_network_security_group" "example" {
  name                = var.network_security_group_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = var.tags
}

# Subnets
resource "azurerm_subnet" "app" {
  name                 = "${var.subnet_prefix}-app"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "data" {
  name                 = "${var.subnet_prefix}-data"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "gateway" {
  name                 = "${var.subnet_prefix}-gateway"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.3.0/24"]
}

# Route Table
module "route_table" {
  source = "../../"

  name                          = var.route_table_name
  resource_group_name           = azurerm_resource_group.example.name
  location                      = azurerm_resource_group.example.location
  bgp_route_propagation_enabled = false

  routes = [
    {
      name                   = "to-firewall"
      address_prefix         = "10.0.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.1.0.4"
    },
    {
      name           = "to-internet"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
  ]

  tags = var.tags
}

# Subnet Route Table Associations - managed at wrapper level
resource "azurerm_subnet_route_table_association" "app" {
  subnet_id      = azurerm_subnet.app.id
  route_table_id = module.route_table.id
}

resource "azurerm_subnet_route_table_association" "data" {
  subnet_id      = azurerm_subnet.data.id
  route_table_id = module.route_table.id
}

# Note: Gateway subnet typically doesn't need route table association

# Subnet NSG Associations - also managed at wrapper level
resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.example.id
}

resource "azurerm_subnet_network_security_group_association" "data" {
  subnet_id                 = azurerm_subnet.data.id
  network_security_group_id = azurerm_network_security_group.example.id
}