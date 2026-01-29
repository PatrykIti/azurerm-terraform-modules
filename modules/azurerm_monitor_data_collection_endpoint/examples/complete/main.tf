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
  name     = var.resource_group_name
  location = var.location
}

module "monitor_data_collection_endpoint" {
  source = "../.."

  name                = var.endpoint_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind                          = var.kind
  public_network_access_enabled = var.public_network_access_enabled
  description                   = var.description

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}
