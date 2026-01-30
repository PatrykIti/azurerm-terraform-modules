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
  name     = "rg-ai-services-network-${var.random_suffix}"
  location = var.location
}

module "ai_services_account" {
  source = "../../../"

  name                = "aiservices-network-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "S0"

  custom_subdomain_name = "aiservices${var.random_suffix}"
  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = [var.allowed_ip_range]
  }

  tags = var.tags
}
