# Complete Event Hub Example

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
  suffix         = var.random_suffix == "" ? "" : "-${var.random_suffix}"
  suffix_compact = var.random_suffix == "" ? "" : lower(replace(var.random_suffix, "-", ""))
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

  sku = "Standard"

  tags = {
    Environment = "Development"
    Example     = "Complete-namespace"
  }
}

resource "azurerm_storage_account" "example" {
  name                     = "${var.storage_account_name}${local.suffix_compact}"
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
  source = "../../../"

  name              = "${var.eventhub_name}${local.suffix}"
  namespace_id      = module.eventhub_namespace.id
  partition_count   = 4
  message_retention = 3

  status = "Active"

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

  consumer_groups = [
    {
      name          = "cg-analytics"
      user_metadata = "analytics"
    },
    {
      name          = "cg-ingest"
      user_metadata = "ingest"
    }
  ]

  authorization_rules = [
    {
      name = "send-only"
      send = true
    },
    {
      name   = "listen-only"
      listen = true
    },
    {
      name   = "manage-all"
      manage = true
      listen = true
      send   = true
    }
  ]
}
