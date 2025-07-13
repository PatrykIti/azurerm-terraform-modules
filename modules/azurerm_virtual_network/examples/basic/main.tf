provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-virtual_network-basic-example"
  location = "West Europe"
}

module "virtual_network" {
  source = "../../"

  name                = "virtualnetworkexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
