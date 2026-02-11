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
  name     = "rg-cog-negative"
  location = "westeurope"
}

module "cognitive_account" {
  source = "../../.."

  name                = "a"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind     = "OpenAI"
  sku_name = "S0"

  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}
