# Network Event Hub Example

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

locals {
  suffix = var.random_suffix == "" ? "" : "-${var.random_suffix}"
}

resource "azurerm_resource_group" "example" {
  name     = "${var.resource_group_name}${local.suffix}"
  location = var.location
}

module "eventhub_namespace" {
  source = "../../../../azurerm_eventhub_namespace"

  name                = "${var.namespace_name}${local.suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku                           = "Standard"
  public_network_access_enabled = true

  network_rule_set = {
    default_action                 = "Deny"
    public_network_access_enabled  = true
    trusted_service_access_enabled = true
    ip_rules = [
      {
        ip_mask = "203.0.113.0/24"
      }
    ]
  }

  tags = {
    Environment = "Development"
    Example     = "Network-namespace"
  }
}

module "eventhub" {
  source = "../../../"

  name            = "${var.eventhub_name}${local.suffix}"
  namespace_id    = module.eventhub_namespace.id
  partition_count = 2
}
