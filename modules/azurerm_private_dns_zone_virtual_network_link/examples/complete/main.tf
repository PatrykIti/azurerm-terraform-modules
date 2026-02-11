provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-private-dns-zone-link-complete-example"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-pdns-link-complete"
  address_space       = ["10.20.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone" "example" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

module "private_dns_zone_virtual_network_link" {
  source = "../../"

  name                  = "pdns-link-complete"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = azurerm_virtual_network.example.id

  registration_enabled = true
  resolution_policy    = "Default"

  tags = {
    Environment = "Production"
    Example     = "Complete"
  }
}
