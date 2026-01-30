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
  name     = var.resource_group_name
  location = var.location
}

module "redis_cache" {
  source = "../.."

  name                = var.redis_cache_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku_name = "Standard"
  family   = "C"
  capacity = 1

  firewall_rules = [
    {
      name             = "office"
      start_ip_address = "198.51.100.10"
      end_ip_address   = "198.51.100.20"
    },
    {
      name             = "vpn"
      start_ip_address = "203.0.113.0"
      end_ip_address   = "203.0.113.255"
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Firewall-Rules"
  }
}
