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
  name     = "rg-pdns-link-negative-test"
  location = "West Europe"
}

module "private_dns_zone_virtual_network_link" {
  source = "../../../"

  name                  = "pdns-link-negative"
  resource_group_name   = azurerm_resource_group.test.name
  private_dns_zone_name = "invalid_name"
  virtual_network_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-test"

  tags = {
    Environment = "Test"
    Scenario    = "Negative"
  }
}
