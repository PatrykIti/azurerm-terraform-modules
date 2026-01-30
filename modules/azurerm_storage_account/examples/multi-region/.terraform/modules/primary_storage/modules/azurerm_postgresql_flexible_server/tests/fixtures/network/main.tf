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

resource "azurerm_resource_group" "test" {
  name     = "rg-pgfs-network-${var.random_suffix}"
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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv2.1.0"

  name                = "pgfsnetwork${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  server = {
    sku_name           = "GP_Standard_D2s_v3"
    postgresql_version = "15"
  }

  authentication = {
    administrator = {
      login    = "pgfsadmin"
      password = random_password.admin.result
    }
  }

  network = {
    public_network_access_enabled = true
    firewall_rules = [
      {
        name             = "office-range"
        start_ip_address = "203.0.113.0"
        end_ip_address   = "203.0.113.255"
      }
    ]
  }

  tags = {
    Environment = "Test"
    Scenario    = "Network"
  }
}
