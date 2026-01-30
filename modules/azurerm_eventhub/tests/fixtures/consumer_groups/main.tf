# Event Hub Consumer Groups Example

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
  source = "../../../azurerm_eventhub_namespace"

  name                = "${var.namespace_name}${local.suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku = "Standard"

  tags = {
    Environment = "Development"
    Example     = "ConsumerGroups-namespace"
  }
}

module "eventhub" {
  source = "../../"

  name            = "${var.eventhub_name}${local.suffix}"
  namespace_id    = module.eventhub_namespace.id
  partition_count = 2

  consumer_groups = [
    {
      name          = "cg-ingest"
      user_metadata = "ingest"
    },
    {
      name          = "cg-analytics"
      user_metadata = "analytics"
    }
  ]
}
