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
  name     = "rg-pdns-basic-${var.random_suffix}"
  location = var.location
}

module "private_dns_zone" {
  source = "../../../"

  name                = "example-${var.random_suffix}.internal"
  resource_group_name = azurerm_resource_group.example.name

  tags = var.tags
}
