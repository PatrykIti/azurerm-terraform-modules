provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-virtual_network-secure-example"
  location = "West Europe"
}

module "virtual_network" {
  source = "../../"

  name                = "virtualnetworkexample003"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Add security-focused configuration here

  tags = {
    Environment = "Production"
    Example     = "Secure"
  }
}
