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
  name     = "rg-appins-smart-${var.random_suffix}"
  location = var.location
}

module "application_insights" {
  source = "../../.."

  name                = "appi-smart-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  application_type    = "web"

  smart_detection_rules = [
    {
      name    = "Slow server response time"
      enabled = true
    }
  ]

  tags = {
    Environment = "Test"
    Example     = "Smart Detection"
  }
}
