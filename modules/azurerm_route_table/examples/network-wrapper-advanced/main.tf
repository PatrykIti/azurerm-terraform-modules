terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.36.0"
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
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = [each.value.address_prefix]
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

# Subnet Route Table Associations - simplified approach
resource "azurerm_subnet_route_table_association" "associations" {
  for_each = {
    for subnet_key, subnet_config in var.subnets :
    subnet_key => subnet_config
    if subnet_config.associate_route_table == true
  }

  subnet_id      = azurerm_subnet.subnets[each.key].id
  route_table_id = module.route_table.id
}

# Subnet NSG Associations - simplified approach
resource "azurerm_subnet_network_security_group_association" "associations" {
  for_each = {
    for subnet_key, subnet_config in var.subnets :
    subnet_key => subnet_config
    if subnet_config.associate_nsg == true
  }

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.example.id
}