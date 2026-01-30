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
  name     = "rg-cog-network-${var.random_suffix}"
  location = var.location
}

module "cognitive_account" {
  source = "../../.."

  name                = "cogopenai${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind     = "OpenAI"
  sku_name = "S0"

  custom_subdomain_name         = "cogopenai${var.random_suffix}"
  public_network_access_enabled = true
  local_auth_enabled            = true

  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = ["203.0.113.0/24"]
  }

  tags = var.tags
}
