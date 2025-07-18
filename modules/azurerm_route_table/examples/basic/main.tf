# Basic Route Table Example

# Resource Group
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "example" {
  name     = "rg-rt-basic-${random_string.suffix.result}"
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "vnet-rt-basic-${random_string.suffix.result}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet
resource "azurerm_subnet" "example" {
  name                 = "snet-rt-basic-${random_string.suffix.result}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Basic Route Table
module "route_table" {
  source = "../../"

  name                = "rt-basic-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Simple routes configuration
  routes = [
    {
      name           = "to-internet"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    },
    {
      name           = "local-vnet"
      address_prefix = "10.0.0.0/16"
      next_hop_type  = "VnetLocal"
    }
  ]

  # Associate with subnet
  subnet_ids_to_associate = [
    azurerm_subnet.example.id
  ]

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
