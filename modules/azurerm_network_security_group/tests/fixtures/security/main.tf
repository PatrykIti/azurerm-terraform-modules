provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-network_security_group-secure-example"
  location = "West Europe"
}

module "network_security_group" {
  source = "../../.."

  name                = "networksecuritygroupexample003"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Add security-focused configuration here

  tags = {
    Environment = "Production"
    Example     = "Secure"
  }
}
