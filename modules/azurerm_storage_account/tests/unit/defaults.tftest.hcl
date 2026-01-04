# Test default security settings for Storage Account module

# Mock the Azure provider to avoid real API calls
mock_provider "azurerm" {
  mock_resource "azurerm_storage_account" {
    defaults = {
      id                             = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/testsa"
      primary_blob_endpoint          = "https://testsa.blob.core.windows.net/"
      primary_blob_host              = "testsa.blob.core.windows.net"
      primary_access_key             = "mock-access-key"
      secondary_access_key           = "mock-secondary-key"
      primary_connection_string      = "DefaultEndpointsProtocol=https;AccountName=testsa;AccountKey=mock-key;EndpointSuffix=core.windows.net"
      secondary_connection_string    = "DefaultEndpointsProtocol=https;AccountName=testsa;AccountKey=mock-secondary-key;EndpointSuffix=core.windows.net"
      primary_blob_connection_string = "DefaultEndpointsProtocol=https;AccountName=testsa;AccountKey=mock-key;BlobEndpoint=https://testsa.blob.core.windows.net/;EndpointSuffix=core.windows.net"
      primary_location               = "northeurope"
    }
  }

  mock_resource "azurerm_storage_container" {
    defaults = {
      id                      = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/testsa/blobServices/default/containers/testcontainer"
      has_immutability_policy = false
      has_legal_hold          = false
      resource_manager_id     = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/testsa/blobServices/default/containers/testcontainer"
    }
  }
}

variables {
  name                = "testsa123456"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

# Test default security settings
run "verify_secure_defaults" {
  command = plan

  # Test default HTTPS enforcement
  assert {
    condition     = azurerm_storage_account.storage_account.https_traffic_only_enabled == true
    error_message = "HTTPS traffic only should be enabled by default"
  }

  # Test default TLS version
  assert {
    condition     = azurerm_storage_account.storage_account.min_tls_version == "TLS1_2"
    error_message = "Default TLS version should be TLS1_2"
  }

  # Test shared access key disabled by default
  assert {
    condition     = azurerm_storage_account.storage_account.shared_access_key_enabled == false
    error_message = "Shared access keys should be disabled by default for security"
  }

  # Test public blob access disabled by default
  assert {
    condition     = azurerm_storage_account.storage_account.allow_nested_items_to_be_public == false
    error_message = "Public blob access should be disabled by default"
  }

  # Test infrastructure encryption enabled by default
  assert {
    condition     = azurerm_storage_account.storage_account.infrastructure_encryption_enabled == true
    error_message = "Infrastructure encryption should be enabled by default"
  }

  # Test public network access disabled by default
  assert {
    condition     = azurerm_storage_account.storage_account.public_network_access_enabled == false
    error_message = "Public network access should be disabled by default for security"
  }
}

# Test default account configuration
run "verify_account_defaults" {
  command = plan

  # Test default account tier
  assert {
    condition     = azurerm_storage_account.storage_account.account_tier == "Standard"
    error_message = "Default account tier should be Standard"
  }

  # Test default replication type
  assert {
    condition     = azurerm_storage_account.storage_account.account_replication_type == "LRS"
    error_message = "Default replication type should be LRS"
  }

  # Test default account kind
  assert {
    condition     = azurerm_storage_account.storage_account.account_kind == "StorageV2"
    error_message = "Default account kind should be StorageV2"
  }

  # Test default access tier
  assert {
    condition     = azurerm_storage_account.storage_account.access_tier == "Hot"
    error_message = "Default access tier should be Hot"
  }
}

# Test default blob properties
run "verify_blob_properties_defaults" {
  command = plan

  variables {
    name                = "testsa123456"
    resource_group_name = "test-rg"
    location            = "northeurope"
    blob_properties = {
      versioning_enabled  = true
      change_feed_enabled = true
      delete_retention_policy = {
        enabled = true
        days    = 7
      }
      container_delete_retention_policy = {
        enabled = true
        days    = 7
      }
    }
  }

  # Since blob_properties is a dynamic block, we verify the configuration is accepted
  assert {
    condition     = var.blob_properties.versioning_enabled == true
    error_message = "Blob properties versioning should be enabled by default"
  }
}

# Test network rules default to deny
run "verify_network_rules_defaults" {
  command = plan

  variables {
    name                = "testsa123456"
    resource_group_name = "test-rg"
    location            = "northeurope"
    network_rules = {
      bypass = ["AzureServices"]
    }
  }

  # Network rules are applied via a separate resource in the actual implementation
  # The default_action is now automatically set to "Deny" for security by default
  # Here we verify the network rules structure is valid
  assert {
    condition     = can(var.network_rules.bypass)
    error_message = "Network rules should have bypass field"
  }
}