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
  name     = "rg-pdns-negative-test"
  location = "West Europe"
}

module "private_dns_zone" {
  source = "../../../"

  name                = "invalid_name"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    Environment = "Test"
    Scenario    = "Negative"
  }
}
