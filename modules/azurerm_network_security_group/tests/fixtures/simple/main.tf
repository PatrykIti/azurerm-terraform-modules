provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-network_security_group-basic-example"
  location = "West Europe"
}

module "network_security_group" {
  source = "../../"

  name                = "networksecuritygroupexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
