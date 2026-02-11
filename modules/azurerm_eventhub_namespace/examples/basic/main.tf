# Basic Event Hub Namespace Example

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

module "eventhub_namespace" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_eventhub_namespace?ref=EHNSv1.0.0"

  name                = var.namespace_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku = var.sku

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
