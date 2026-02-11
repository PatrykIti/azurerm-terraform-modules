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

resource "azurerm_resource_group" "test" {
  name     = "rg-dpc-smp-${var.random_suffix}"
  location = var.location
}

module "storage_account" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_postgresql_flexible_server?ref=PGFSv1.1.0"

  name                     = "dpcsmp${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = var.account_replication_type

  # Enable shared access key for tests
  security_settings = {
    shared_access_key_enabled = true
  }

  blob_properties = {
    versioning_enabled = var.enable_blob_versioning
  }

  tags = {
    Environment = "Test"
    TestType    = "Simple"
  }
}

output "storage_account_name" {
  value = module.storage_account.name
}

output "storage_account_id" {
  value = module.storage_account.id
}

output "resource_group_name" {
  value = azurerm_resource_group.test.name
}

output "primary_blob_endpoint" {
  value = module.storage_account.primary_blob_endpoint
}