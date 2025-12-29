provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-nsg-smp-${var.random_suffix}"
  location = var.location
}

module "network_security_group" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_route_table?ref=RTv1.0.4"

  name                = "nsg-smp-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags                = var.tags
}
