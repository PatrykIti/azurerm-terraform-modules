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
  name     = "rg-cog-speech-${var.random_suffix}"
  location = var.location
}

module "cognitive_account" {
  source = "../../.."

  name                = "cogspeech${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind     = "SpeechServices"
  sku_name = "S0"

  public_network_access_enabled = true
  local_auth_enabled            = true

  tags = var.tags
}
