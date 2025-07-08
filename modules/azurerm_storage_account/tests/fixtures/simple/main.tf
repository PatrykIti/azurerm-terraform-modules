provider "azurerm" {
  features {}
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "test" {
  name     = "rg-test-storage-simple-${var.random_suffix}"
  location = var.location
}

module "storage_account" {
  source = "../../../"

  name                     = "devtmpciti${random_string.suffix.result}${var.random_suffix}"
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