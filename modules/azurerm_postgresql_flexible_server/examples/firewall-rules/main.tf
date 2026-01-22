terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
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

resource "random_password" "admin" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  special     = false
}

module "postgresql_flexible_server" {
  source = "../../"

  name                = var.server_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku_name           = var.sku_name
  postgresql_version = var.postgresql_version

  administrator_login    = var.administrator_login
  administrator_password = random_password.admin.result

  network = {
    public_network_access_enabled = true
  }

  firewall_rules = [
    {
      name             = "office-range"
      start_ip_address = "203.0.113.0"
      end_ip_address   = "203.0.113.255"
    },
    {
      name             = "vpn-ip"
      start_ip_address = "198.51.100.10"
      end_ip_address   = "198.51.100.10"
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "FirewallRules"
  }
}
