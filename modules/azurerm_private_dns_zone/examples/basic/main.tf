provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-private-dns-zone-basic-example"
  location = var.location
}

module "private_dns_zone" {
  source = "../../"

  name                = "example.internal"
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
