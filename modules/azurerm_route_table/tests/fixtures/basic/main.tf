provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-route_table-basic-example"
  location = "West Europe"
}

module "route_table" {
  source = "../../"

  name                = "routetableexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
