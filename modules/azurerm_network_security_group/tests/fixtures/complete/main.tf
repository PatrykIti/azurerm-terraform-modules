provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-network_security_group-complete-example"
  location = "West Europe"
}

module "network_security_group" {
  source = "../../.."

  name                = "networksecuritygroupexample002"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Add more comprehensive configuration here

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}
