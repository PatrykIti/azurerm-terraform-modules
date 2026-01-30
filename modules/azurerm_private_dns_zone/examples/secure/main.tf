provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-private-dns-zone-secure-example"
  location = var.location
}

module "private_dns_zone" {
  source = "../../"

  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment        = "Production"
    Example            = "Secure"
    DataClassification = "Confidential"
  }
}
