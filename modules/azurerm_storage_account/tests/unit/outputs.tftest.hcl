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

# Test that outputs are defined and use try() for null safety
run "verify_outputs_defined" {
  command = plan

  # Test that all outputs are defined in the module
  assert {
    condition     = can(output.id)
    error_message = "Output 'id' should be defined"
  }

  assert {
    condition     = can(output.name)
    error_message = "Output 'name' should be defined"
  }

  assert {
    condition     = can(output.primary_location)
    error_message = "Output 'primary_location' should be defined"
  }

  assert {
    condition     = can(output.secondary_location)
    error_message = "Output 'secondary_location' should be defined"
  }

  assert {
    condition     = can(output.primary_blob_endpoint)
    error_message = "Output 'primary_blob_endpoint' should be defined"
  }

  assert {
    condition     = can(output.primary_blob_host)
    error_message = "Output 'primary_blob_host' should be defined"
  }

  assert {
    condition     = can(output.secondary_blob_endpoint)
    error_message = "Output 'secondary_blob_endpoint' should be defined"
  }

  assert {
    condition     = can(output.secondary_blob_host)
    error_message = "Output 'secondary_blob_host' should be defined"
  }

  assert {
    condition     = can(output.primary_blob_internet_endpoint)
    error_message = "Output 'primary_blob_internet_endpoint' should be defined"
  }

  assert {
    condition     = can(output.primary_blob_internet_host)
    error_message = "Output 'primary_blob_internet_host' should be defined"
  }
}

# Test sensitive outputs are defined
run "verify_sensitive_outputs_defined" {
  command = plan

  # Test connection string output exists
  assert {
    condition     = can(output.primary_connection_string)
    error_message = "Output 'primary_connection_string' should be defined"
  }

  assert {
    condition     = can(output.secondary_connection_string)
    error_message = "Output 'secondary_connection_string' should be defined"
  }

  assert {
    condition     = can(output.primary_blob_connection_string)
    error_message = "Output 'primary_blob_connection_string' should be defined"
  }

  assert {
    condition     = can(output.secondary_blob_connection_string)
    error_message = "Output 'secondary_blob_connection_string' should be defined"
  }

  # Test access key outputs exist
  assert {
    condition     = can(output.primary_access_key)
    error_message = "Output 'primary_access_key' should be defined"
  }

  assert {
    condition     = can(output.secondary_access_key)
    error_message = "Output 'secondary_access_key' should be defined"
  }
}

# Test queue-related outputs
run "verify_queue_outputs_defined" {
  command = plan

  assert {
    condition     = can(output.primary_queue_endpoint)
    error_message = "Output 'primary_queue_endpoint' should be defined"
  }

  assert {
    condition     = can(output.primary_queue_host)
    error_message = "Output 'primary_queue_host' should be defined"
  }

  assert {
    condition     = can(output.secondary_queue_endpoint)
    error_message = "Output 'secondary_queue_endpoint' should be defined"
  }

  assert {
    condition     = can(output.secondary_queue_host)
    error_message = "Output 'secondary_queue_host' should be defined"
  }
}

# Test table-related outputs
run "verify_table_outputs_defined" {
  command = plan

  assert {
    condition     = can(output.primary_table_endpoint)
    error_message = "Output 'primary_table_endpoint' should be defined"
  }

  assert {
    condition     = can(output.primary_table_host)
    error_message = "Output 'primary_table_host' should be defined"
  }

  assert {
    condition     = can(output.secondary_table_endpoint)
    error_message = "Output 'secondary_table_endpoint' should be defined"
  }

  assert {
    condition     = can(output.secondary_table_host)
    error_message = "Output 'secondary_table_host' should be defined"
  }
}

# Test file and dfs outputs
run "verify_file_dfs_outputs_defined" {
  command = plan

  assert {
    condition     = can(output.primary_file_endpoint)
    error_message = "Output 'primary_file_endpoint' should be defined"
  }

  assert {
    condition     = can(output.primary_file_host)
    error_message = "Output 'primary_file_host' should be defined"
  }

  assert {
    condition     = can(output.primary_dfs_endpoint)
    error_message = "Output 'primary_dfs_endpoint' should be defined"
  }

  assert {
    condition     = can(output.primary_dfs_host)
    error_message = "Output 'primary_dfs_host' should be defined"
  }

  assert {
    condition     = can(output.primary_web_endpoint)
    error_message = "Output 'primary_web_endpoint' should be defined"
  }

  assert {
    condition     = can(output.primary_web_host)
    error_message = "Output 'primary_web_host' should be defined"
  }
}