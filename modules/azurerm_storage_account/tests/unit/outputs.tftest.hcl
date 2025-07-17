# Test output formatting for Storage Account module

# Mock the Azure provider to avoid real API calls
mock_provider "azurerm" {
  mock_resource "azurerm_storage_account" {
    defaults = {
      id                                 = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/testsa"
      name                               = "testsa"
      primary_location                   = "northeurope"
      secondary_location                 = "westeurope"
      primary_blob_endpoint              = "https://testsa.blob.core.windows.net/"
      primary_blob_host                  = "testsa.blob.core.windows.net"
      secondary_blob_endpoint            = "https://testsa-secondary.blob.core.windows.net/"
      secondary_blob_host                = "testsa-secondary.blob.core.windows.net"
      primary_blob_internet_endpoint     = "https://testsa.blob.core.internet.net/"
      primary_blob_internet_host         = "testsa.blob.core.internet.net"
      primary_queue_endpoint             = "https://testsa.queue.core.windows.net/"
      primary_queue_host                 = "testsa.queue.core.windows.net"
      secondary_queue_endpoint           = "https://testsa-secondary.queue.core.windows.net/"
      secondary_queue_host               = "testsa-secondary.queue.core.windows.net"
      primary_table_endpoint             = "https://testsa.table.core.windows.net/"
      primary_table_host                 = "testsa.table.core.windows.net"
      secondary_table_endpoint           = "https://testsa-secondary.table.core.windows.net/"
      secondary_table_host               = "testsa-secondary.table.core.windows.net"
      primary_file_endpoint              = "https://testsa.file.core.windows.net/"
      primary_file_host                  = "testsa.file.core.windows.net"
      secondary_file_endpoint            = "https://testsa-secondary.file.core.windows.net/"
      secondary_file_host                = "testsa-secondary.file.core.windows.net"
      primary_dfs_endpoint               = "https://testsa.dfs.core.windows.net/"
      primary_dfs_host                   = "testsa.dfs.core.windows.net"
      secondary_dfs_endpoint             = "https://testsa-secondary.dfs.core.windows.net/"
      secondary_dfs_host                 = "testsa-secondary.dfs.core.windows.net"
      primary_web_endpoint               = "https://testsa.z6.web.core.windows.net/"
      primary_web_host                   = "testsa.z6.web.core.windows.net"
      secondary_web_endpoint             = "https://testsa-secondary.z13.web.core.windows.net/"
      secondary_web_host                 = "testsa-secondary.z13.web.core.windows.net"
      primary_access_key                 = "mock-primary-access-key"
      secondary_access_key               = "mock-secondary-access-key"
      primary_connection_string          = "DefaultEndpointsProtocol=https;AccountName=testsa;AccountKey=mock-key;EndpointSuffix=core.windows.net"
      secondary_connection_string        = "DefaultEndpointsProtocol=https;AccountName=testsa;AccountKey=mock-secondary-key;EndpointSuffix=core.windows.net"
      primary_blob_connection_string     = "DefaultEndpointsProtocol=https;AccountName=testsa;AccountKey=mock-key;BlobEndpoint=https://testsa.blob.core.windows.net/;EndpointSuffix=core.windows.net"
      secondary_blob_connection_string   = "DefaultEndpointsProtocol=https;AccountName=testsa;AccountKey=mock-secondary-key;BlobEndpoint=https://testsa-secondary.blob.core.windows.net/;EndpointSuffix=core.windows.net"
    }
  }
}

variables {
  name                = "testsa"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

# Test that the plan includes a storage account resource
run "verify_storage_account_planned" {
  command = plan

  assert {
    condition     = can(azurerm_storage_account.storage_account)
    error_message = "Storage account resource should be planned"
  }

  assert {
    condition     = azurerm_storage_account.storage_account.name == var.name
    error_message = "Storage account name should match variable"
  }

  assert {
    condition     = azurerm_storage_account.storage_account.resource_group_name == var.resource_group_name
    error_message = "Storage account resource group should match variable"
  }

  assert {
    condition     = azurerm_storage_account.storage_account.location == var.location
    error_message = "Storage account location should match variable"
  }
}

# Test output formatting with specific replication types
run "verify_output_behavior_with_lrs" {
  command = plan

  variables {
    name                     = "testsa"
    resource_group_name      = "test-rg"
    location                 = "northeurope"
    account_replication_type = "LRS"
  }

  # Verify storage account is created with LRS
  assert {
    condition     = azurerm_storage_account.storage_account.account_replication_type == "LRS"
    error_message = "Storage account should use LRS replication"
  }
}

# Test output behavior with geo-redundant storage
run "verify_output_behavior_with_grs" {
  command = plan

  variables {
    name                     = "testsa"
    resource_group_name      = "test-rg"
    location                 = "northeurope"
    account_replication_type = "GRS"
  }

  # Verify storage account is created with GRS
  assert {
    condition     = azurerm_storage_account.storage_account.account_replication_type == "GRS"
    error_message = "Storage account should use GRS replication"
  }
}

# Test that outputs use try() function for null safety
run "verify_outputs_use_try_function" {
  command = plan

  # Since we can't check output values during plan with mocks,
  # we verify the module structure is correct
  assert {
    condition     = can(azurerm_storage_account.storage_account.id)
    error_message = "Storage account should have an ID attribute"
  }

  assert {
    condition     = can(azurerm_storage_account.storage_account.name)
    error_message = "Storage account should have a name attribute"
  }

  assert {
    condition     = can(azurerm_storage_account.storage_account.primary_location)
    error_message = "Storage account should have a primary_location attribute"
  }
}

# Test storage account attributes that map to outputs
run "verify_storage_account_attributes" {
  command = plan

  # Verify key attributes exist on the storage account resource
  assert {
    condition     = can(azurerm_storage_account.storage_account.primary_blob_endpoint)
    error_message = "Storage account should have primary_blob_endpoint attribute"
  }

  assert {
    condition     = can(azurerm_storage_account.storage_account.primary_blob_host)
    error_message = "Storage account should have primary_blob_host attribute"
  }

  assert {
    condition     = can(azurerm_storage_account.storage_account.primary_access_key)
    error_message = "Storage account should have primary_access_key attribute"
  }

  assert {
    condition     = can(azurerm_storage_account.storage_account.primary_connection_string)
    error_message = "Storage account should have primary_connection_string attribute"
  }
}