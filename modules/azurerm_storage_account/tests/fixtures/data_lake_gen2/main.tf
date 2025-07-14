provider "azurerm" {
  features {}
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "test" {
  name     = "rg-dpc-dlg-${var.random_suffix}"
  location = var.location
}

# Virtual Network for NFSv3 Support
resource "azurerm_virtual_network" "test" {
  name                = "vnet-dpc-dlg-${var.random_suffix}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "snet-dpc-dlg-nfs"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
}

module "storage_account" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.0.0"

  name                     = "dpcdlg${random_string.suffix.result}${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"

  # Enable Data Lake Gen2 features
  is_hns_enabled     = true
  sftp_enabled       = true
  nfsv3_enabled      = true
  local_user_enabled = true

  # Security settings
  security_settings = {
    https_traffic_only_enabled      = true
    min_tls_version                 = "TLS1_2"
    shared_access_key_enabled       = true
    allow_nested_items_to_be_public = false
  }

  # Network configuration
  network_rules = {
    default_action             = "Allow"
    bypass                     = ["AzureServices"]
    ip_rules                   = []
    virtual_network_subnet_ids = [azurerm_subnet.test.id]
  }

  # Enable identity
  identity = {
    type = "SystemAssigned"
  }

  # Blob properties
  blob_properties = {
    versioning_enabled       = true
    change_feed_enabled      = true
    last_access_time_enabled = true

    delete_retention_policy = {
      enabled = true
      days    = 7
    }

    container_delete_retention_policy = {
      enabled = true
      days    = 7
    }
  }

  # Simple lifecycle rule for testing
  lifecycle_rules = [
    {
      name    = "test-cleanup"
      enabled = true

      filters = {
        blob_types   = ["blockBlob"]
        prefix_match = ["temp/"]
      }

      actions = {
        base_blob = {
          delete_after_days_since_modification_greater_than = 7
        }
      }
    }
  ]

  tags = {
    Environment = "Test"
    TestType    = "DataLakeGen2"
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

output "primary_dfs_endpoint" {
  value = module.storage_account.primary_dfs_endpoint
}

output "is_hns_enabled" {
  value = module.storage_account.is_hns_enabled
}

output "sftp_enabled" {
  value = module.storage_account.sftp_enabled
}

output "nfsv3_enabled" {
  value = module.storage_account.nfsv3_enabled
}

output "subnet_id" {
  value = azurerm_subnet.test.id
}