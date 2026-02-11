provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-private-dns-zone-link-secure-example"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-pdns-link-secure"
  address_space       = ["10.30.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone" "example" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.example.name
}

module "private_dns_zone_virtual_network_link" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_private_dns_zone_virtual_network_link?ref=PDNSZLNKv1.0.0"

  name                  = "pdns-link-secure"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = azurerm_virtual_network.example.id

  registration_enabled = false

  tags = {
    Environment = "Production"
    Example     = "Secure"
    Owner       = "Network"
  }
}
