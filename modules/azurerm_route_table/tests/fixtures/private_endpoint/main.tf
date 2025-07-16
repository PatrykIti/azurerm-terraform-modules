provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-route_table-private-endpoint-example"
  location = "West Europe"
}

# Virtual Network for private endpoint
resource "azurerm_virtual_network" "example" {
  name                = "vnet-route_table-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "private_endpoint" {
  name                 = "subnet-private-endpoint"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "route_table" {
  source = "../../"

  name                = "routetableexample004"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Disable public access for private endpoint scenario
  security_settings = {
    public_network_access_enabled = false
  }

  # Configure private endpoint
  private_endpoints = [
    {
      name      = "pe-route_table-example"
      subnet_id = azurerm_subnet.private_endpoint.id
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Private-Endpoint"
  }
}
