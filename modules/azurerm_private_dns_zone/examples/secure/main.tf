provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-private-dns-zone-secure-example"
  location = var.location
}

module "private_dns_zone" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_private_dns_zone?ref=PDNSZv1.0.0"

  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment        = "Production"
    Example            = "Secure"
    DataClassification = "Confidential"
  }
}
