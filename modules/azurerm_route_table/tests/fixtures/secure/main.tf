provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-route_table-secure-example"
  location = "West Europe"
}

module "route_table" {
  source = "../../.."

  name                = "routetableexample003"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Add security-focused configuration here

  tags = {
    Environment = "Production"
    Example     = "Secure"
  }
}
