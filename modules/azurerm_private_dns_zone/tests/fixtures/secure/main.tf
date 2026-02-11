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
  name     = "rg-pdns-secure-${var.random_suffix}"
  location = var.location
}

module "private_dns_zone" {
  source = "../../../"

  name                = "privatelink-${var.random_suffix}.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.example.name

  tags = var.tags
}
