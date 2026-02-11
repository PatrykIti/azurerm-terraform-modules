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
  name     = "rg-pgfs-negative-test"
  location = "westeurope"
}

resource "random_password" "admin" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  special     = false
}

# This should fail due to invalid name
module "postgresql_flexible_server" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_postgresql_flexible_server?ref=PGFSv1.1.0"

  name                = "INVALID-NAME-WITH-UPPERCASE"
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

  tags = {
    Environment = "Test"
    Scenario    = "Negative"
  }
}
