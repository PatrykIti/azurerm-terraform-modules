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

module "monitor_private_link_scope" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_monitor_private_link_scope?ref=AMPLSv1.0.0"

  name                = var.scope_name
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
