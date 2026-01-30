terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-pdns-complete-${var.random_suffix}"
  location = var.location
}

module "private_dns_zone" {
  source = "../../../"

  name                = "privatelink-${var.random_suffix}.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name

  soa_record = {
    email        = "hostmaster.example.internal"
    ttl          = 3600
    refresh_time = 3600
    retry_time   = 300
    expire_time  = 2419200
    minimum_ttl  = 300
  }

  tags = var.tags
}
