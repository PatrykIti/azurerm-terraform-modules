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
  name     = "rg-pgfsdb-secure-${var.random_suffix}"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-pgfsdb-secure-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.40.0.0/16"]
}

resource "azurerm_subnet" "postgresql" {
  name                 = "snet-pgfsdb-secure-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.40.1.0/24"]

  delegation {
    name = "postgresql-flexible-server"

    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_private_dns_zone" "postgresql" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgresql" {
  name                  = "pdzvnet-pgfsdb-secure-${var.random_suffix}"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.postgresql.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

resource "random_password" "admin" {
  length      = 24
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  special     = false
}

module "postgresql_flexible_server" {
  source = "../../../../azurerm_postgresql_flexible_server"

  name                = "pgfsdbsecure${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  server = {
    sku_name           = var.sku_name
    postgresql_version = var.postgresql_version
  }

  authentication = {
    administrator = {
      login    = "pgfsadmin"
      password = random_password.admin.result
    }
  }

  network = {
    public_network_access_enabled = false
    delegated_subnet_id           = azurerm_subnet.postgresql.id
    private_dns_zone_id           = azurerm_private_dns_zone.postgresql.id
  }

  tags = {
    Environment = "Test"
    Example     = "Secure"
  }
}

module "postgresql_flexible_server_database" {
  source = "../../../"

  server = {
    id = module.postgresql_flexible_server.id
  }

  database = {
    name = "appdb${var.random_suffix}"
  }
}
