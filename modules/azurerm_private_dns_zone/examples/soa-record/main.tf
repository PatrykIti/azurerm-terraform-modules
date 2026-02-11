provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-private-dns-zone-soa-example"
  location = var.location
}

module "private_dns_zone" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_private_dns_zone?ref=PDNSZv1.0.0"

  name                = "example.soa.internal"
  resource_group_name = azurerm_resource_group.example.name

  soa_record = {
    email        = "hostmaster.example.internal"
    ttl          = 3600
    refresh_time = 3600
    retry_time   = 300
    expire_time  = 2419200
    minimum_ttl  = 300
  }

  tags = {
    Environment = "Development"
    Example     = "SOA"
  }
}
