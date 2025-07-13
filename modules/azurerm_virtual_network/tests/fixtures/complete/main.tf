provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-virtual_network-complete-example"
  location = "West Europe"
}

module "virtual_network" {
  source = "../../"

  name                = "virtualnetworkexample002"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Add more comprehensive configuration here

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}
