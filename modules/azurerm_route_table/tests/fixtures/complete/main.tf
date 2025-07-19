provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-route_table-complete-example"
  location = "West Europe"
}

module "route_table" {
  source = "../../.."

  name                = "routetableexample002"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Add more comprehensive configuration here

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}
