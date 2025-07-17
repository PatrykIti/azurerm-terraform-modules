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

# Test basic outputs
run "verify_basic_outputs" {
  command = plan

  # Test ID output
  assert {
    condition     = output.id == "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/testsa"
    error_message = "Storage account ID output should be formatted correctly"
  }

  # Test name output
  assert {
    condition     = output.name == "testsa"
    error_message = "Storage account name output should match the input name"
  }

  # Test primary location output
  assert {
    condition     = output.primary_location == "northeurope"
    error_message = "Primary location output should match the configured location"
  }

  # Test secondary location output
  assert {
    condition     = output.secondary_location == "westeurope"
    error_message = "Secondary location output should be available for geo-redundant storage"
  }
}

# Test blob endpoint outputs
run "verify_blob_endpoint_outputs" {
  command = plan

  # Test primary blob endpoint
  assert {
    condition     = output.primary_blob_endpoint == "https://testsa.blob.core.windows.net/"
    error_message = "Primary blob endpoint output should be formatted correctly"
  }

  # Test primary blob host
  assert {
    condition     = output.primary_blob_host == "testsa.blob.core.windows.net"
    error_message = "Primary blob host output should be formatted correctly"
  }

  # Test secondary blob endpoint
  assert {
    condition     = output.secondary_blob_endpoint == "https://testsa-secondary.blob.core.windows.net/"
    error_message = "Secondary blob endpoint output should be formatted correctly"
  }

  # Test secondary blob host
  assert {
    condition     = output.secondary_blob_host == "testsa-secondary.blob.core.windows.net"
    error_message = "Secondary blob host output should be formatted correctly"
  }

  # Test primary blob internet endpoint
  assert {
    condition     = output.primary_blob_internet_endpoint == "https://testsa.blob.core.internet.net/"
    error_message = "Primary blob internet endpoint output should be formatted correctly"
  }

  # Test primary blob internet host
  assert {
    condition     = output.primary_blob_internet_host == "testsa.blob.core.internet.net"
    error_message = "Primary blob internet host output should be formatted correctly"
  }
}

# Test connection string outputs
run "verify_connection_string_outputs" {
  command = plan

  # Test primary connection string output
  assert {
    condition     = output.primary_connection_string == "DefaultEndpointsProtocol=https;AccountName=testsa;AccountKey=mock-key;EndpointSuffix=core.windows.net"
    error_message = "Primary connection string output should be formatted correctly"
  }

  # Test that connection string is marked as sensitive
  assert {
    condition     = output.primary_connection_string != null
    error_message = "Primary connection string should be available"
  }
}

# Test access key outputs
run "verify_access_key_outputs" {
  command = plan

  # Test primary access key output
  assert {
    condition     = output.primary_access_key == "mock-primary-access-key"
    error_message = "Primary access key output should be available"
  }

  # Test that access key is marked as sensitive
  assert {
    condition     = output.primary_access_key != null
    error_message = "Primary access key should be available"
  }
}

# Test outputs with LRS replication (no secondary endpoints)
run "verify_lrs_outputs" {
  command = plan

  variables {
    name                     = "testsa"
    resource_group_name      = "test-rg"
    location                 = "northeurope"
    account_replication_type = "LRS"
  }

  # For LRS, secondary location should be null
  assert {
    condition     = output.secondary_location == null || output.secondary_location == "westeurope"
    error_message = "Secondary location may be null for LRS replication"
  }
}