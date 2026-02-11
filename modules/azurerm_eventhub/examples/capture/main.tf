# Event Hub Capture Example

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

  sku = "Standard"

  tags = {
    Environment = "Development"
    Example     = "Capture-namespace"
  }
}

resource "azurerm_storage_account" "example" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "capture" {
  name                  = "eventhub-capture"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

module "eventhub" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_eventhub?ref=EHv1.0.0"

  name            = var.eventhub_name
  namespace_id    = module.eventhub_namespace.id
  partition_count = 2

  capture_description = {
    enabled             = true
    encoding            = "Avro"
    interval_in_seconds = 300
    size_limit_in_bytes = 10485760
    destination = {
      storage_account_id  = azurerm_storage_account.example.id
      blob_container_name = azurerm_storage_container.capture.name
      archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
    }
  }
}
