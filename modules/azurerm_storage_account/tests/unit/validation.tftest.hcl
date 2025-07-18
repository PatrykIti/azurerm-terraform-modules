# Test variable validation with expected errors for Storage Account module

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
  resource_group_name = "test-rg"
  location            = "northeurope"
}

# Test storage account name too short
run "invalid_storage_account_name_too_short" {
  command = plan

  variables {
    name = "ab" # Too short (minimum is 3)
  }

  expect_failures = [
    var.name,
  ]
}

# Test storage account name too long
run "invalid_storage_account_name_too_long" {
  command = plan

  variables {
    name = "thisstorageaccountnameistoolong123" # Too long (maximum is 24)
  }

  expect_failures = [
    var.name,
  ]
}

# Test storage account name with special characters
run "invalid_storage_account_name_special_chars" {
  command = plan

  variables {
    name = "test-storage-account" # Contains hyphens
  }

  expect_failures = [
    var.name,
  ]
}

# Test storage account name with uppercase letters
run "invalid_storage_account_name_uppercase" {
  command = plan

  variables {
    name = "TestStorageAccount" # Contains uppercase letters
  }

  expect_failures = [
    var.name,
  ]
}

# Test storage account name with spaces
run "invalid_storage_account_name_spaces" {
  command = plan

  variables {
    name = "test storage" # Contains spaces
  }

  expect_failures = [
    var.name,
  ]
}

# Test invalid account tier
run "invalid_account_tier" {
  command = plan

  variables {
    name         = "validstorageaccount"
    account_tier = "Basic" # Invalid tier
  }

  expect_failures = [
    var.account_tier,
  ]
}

# Test invalid replication type
run "invalid_replication_type" {
  command = plan

  variables {
    name                     = "validstorageaccount"
    account_replication_type = "INVALID" # Invalid replication type
  }

  expect_failures = [
    var.account_replication_type,
  ]
}

# Test invalid account kind
run "invalid_account_kind" {
  command = plan

  variables {
    name         = "validstorageaccount"
    account_kind = "InvalidKind" # Invalid account kind
  }

  expect_failures = [
    var.account_kind,
  ]
}

# Test invalid access tier
run "invalid_access_tier" {
  command = plan

  variables {
    name        = "validstorageaccount"
    access_tier = "Warm" # Invalid access tier
  }

  expect_failures = [
    var.access_tier,
  ]
}

# Test invalid TLS version
run "invalid_tls_version" {
  command = plan

  variables {
    name = "validstorageaccount"
    security_settings = {
      min_tls_version = "TLS1_3" # Invalid TLS version
    }
  }

  expect_failures = [
    var.security_settings,
  ]
}

# Test invalid network rules default action
run "invalid_network_rules_default_action" {
  command = plan

  variables {
    name = "validstorageaccount"
    network_rules = {
      default_action = "Block" # Should be "Allow" or "Deny"
    }
  }

  expect_failures = [
    var.network_rules,
  ]
}

# Test invalid container access type
run "invalid_container_access_type" {
  command = plan

  variables {
    name = "validstorageaccount"
    containers = [
      {
        name                  = "testcontainer"
        container_access_type = "public" # Should be "private", "blob", or "container"
      }
    ]
  }

  expect_failures = [
    var.containers,
  ]
}

# Test invalid identity type
run "invalid_identity_type" {
  command = plan

  variables {
    name = "validstorageaccount"
    identity = {
      type = "Invalid" # Should be "SystemAssigned", "UserAssigned", or "SystemAssigned, UserAssigned"
    }
  }

  expect_failures = [
    var.identity,
  ]
}

# Test valid configuration to ensure module works
run "valid_configuration" {
  command = plan

  variables {
    name = "validstorageaccount"
  }

  # This should succeed
  assert {
    condition     = azurerm_storage_account.storage_account.name == "validstorageaccount"
    error_message = "Valid configuration should work"
  }
}