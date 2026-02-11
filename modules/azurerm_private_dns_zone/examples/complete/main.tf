provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-private-dns-zone-complete-example"
  location = var.location
}

module "private_dns_zone" {
  source = "../../"

  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name

  soa_record = {
    email        = "hostmaster.example.internal"
    ttl          = 3600
    refresh_time = 3600
    retry_time   = 300
    expire_time  = 2419200
    minimum_ttl  = 300
    tags = {
      Purpose = "Example"
    }
  }

  tags = {
    Environment = "Production"
    Example     = "Complete"
  }
}
