# Network integration test fixture (public access with firewall rules)
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

resource "azurerm_resource_group" "test" {
  name     = "rg-redis-network-test"
  location = "westeurope"
}

module "redis_cache" {
  source = "../../.."

  name                = "redisnetworktest"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "Standard"
  family   = "C"
  capacity = 1

  firewall_rules = [
    {
      name             = "office"
      start_ip_address = "203.0.113.10"
      end_ip_address   = "203.0.113.20"
    }
  ]

  tags = {
    Environment = "Test"
    Scenario    = "Network"
  }
}
