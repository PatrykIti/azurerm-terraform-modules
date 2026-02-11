# Secure Event Hub Example

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
  source = "../../../azurerm_eventhub_namespace"

  name                = var.namespace_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku                           = "Standard"
  public_network_access_enabled = false

  tags = {
    Environment = "Production"
    Example     = "Secure-namespace"
  }
}

module "eventhub" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_eventhub?ref=EHv1.0.0"

  name            = var.eventhub_name
  namespace_id    = module.eventhub_namespace.id
  partition_count = 2

  status = "Active"
}
