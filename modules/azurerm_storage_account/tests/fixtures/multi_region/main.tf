terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.43.0"
    }
  }
}

provider "azurerm" {
  features {}
}


# Primary region
resource "azurerm_resource_group" "primary" {
  name     = "rg-dpc-mpr-${var.random_suffix}"
  location = var.primary_location
}

# Secondary region
resource "azurerm_resource_group" "secondary" {
  name     = "rg-dpc-msc-${var.random_suffix}"
  location = var.secondary_location
}

# Primary storage account with GRS replication
module "primary_storage" {
  source = "../../.."

  name                     = "dpcmpr${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.primary.name
  location                 = azurerm_resource_group.primary.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "GRS" # Geo-redundant storage
  access_tier              = "Hot"

  # Enable cross-tenant replication
  cross_tenant_replication_enabled = true

  # Security settings
  security_settings = {
    https_traffic_only_enabled      = true
    min_tls_version                 = "TLS1_2"
    shared_access_key_enabled       = true
    allow_nested_items_to_be_public = false
  }

  # Blob properties
  blob_properties = {
    versioning_enabled  = true
    change_feed_enabled = true

    delete_retention_policy = {
      enabled = true
      days    = 7
    }
  }

  # Simple lifecycle rule
  lifecycle_rules = [
    {
      name    = "archive-old"
      enabled = true

      filters = {
        blob_types   = ["blockBlob"]
        prefix_match = ["archive/"]
      }

      actions = {
        base_blob = {
          tier_to_cool_after_days_since_modification_greater_than = 30
        }
      }
    }
  ]

  containers = [
    {
      name                  = "replicated-data"
      container_access_type = "private"
    }
  ]

  tags = {
    Environment = "Test"
    TestType    = "MultiRegion"
    Role        = "Primary"
  }
}

# Secondary storage account in different region
module "secondary_storage" {
  source = "../../../"

  name                     = "dpcmsc${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.secondary.name
  location                 = azurerm_resource_group.secondary.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS" # Local redundancy in secondary region
  access_tier              = "Cool"

  # Security settings
  security_settings = {
    https_traffic_only_enabled      = true
    min_tls_version                 = "TLS1_2"
    shared_access_key_enabled       = true
    allow_nested_items_to_be_public = false
  }

  containers = [
    {
      name                  = "backup-data"
      container_access_type = "private"
    }
  ]

  tags = {
    Environment = "Test"
    TestType    = "MultiRegion"
    Role        = "Secondary"
  }
}

output "primary_storage_account_name" {
  value = module.primary_storage.name
}

output "primary_storage_account_id" {
  value = module.primary_storage.id
}

output "secondary_storage_account_name" {
  value = module.secondary_storage.name
}

output "secondary_storage_account_id" {
  value = module.secondary_storage.id
}

output "primary_resource_group_name" {
  value = azurerm_resource_group.primary.name
}

output "secondary_resource_group_name" {
  value = azurerm_resource_group.secondary.name
}

output "primary_location" {
  value = azurerm_resource_group.primary.location
}

output "secondary_location" {
  value = azurerm_resource_group.secondary.location
}

output "primary_replication_type" {
  value = module.primary_storage.account_replication_type
}