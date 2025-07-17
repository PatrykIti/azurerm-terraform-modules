# Test naming conventions for Storage Account module

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
}

variables {
  resource_group_name = "test-rg"
  location            = "northeurope"
}

# Test valid storage account name
run "valid_storage_account_name" {
  command = plan

  variables {
    name = "validstorageaccount123"
  }

  assert {
    condition     = azurerm_storage_account.storage_account.name == "validstorageaccount123"
    error_message = "Storage account name should be set correctly"
  }
}

# Test minimum length name (3 characters)
run "minimum_length_name" {
  command = plan

  variables {
    name = "abc"
  }

  assert {
    condition     = azurerm_storage_account.storage_account.name == "abc"
    error_message = "Storage account name with 3 characters should be valid"
  }
}

# Test maximum length name (24 characters)
run "maximum_length_name" {
  command = plan

  variables {
    name = "abcdefghijklmnopqrstuvwx"
  }

  assert {
    condition     = azurerm_storage_account.storage_account.name == "abcdefghijklmnopqrstuvwx"
    error_message = "Storage account name with 24 characters should be valid"
  }
}

# Test all lowercase letters
run "all_lowercase_letters" {
  command = plan

  variables {
    name = "onlylowercaseletters"
  }

  assert {
    condition     = azurerm_storage_account.storage_account.name == "onlylowercaseletters"
    error_message = "Storage account name with only lowercase letters should be valid"
  }
}

# Test all numbers
run "all_numbers" {
  command = plan

  variables {
    name = "123456789012"
  }

  assert {
    condition     = azurerm_storage_account.storage_account.name == "123456789012"
    error_message = "Storage account name with only numbers should be valid"
  }
}

# Test combination of letters and numbers
run "letters_and_numbers" {
  command = plan

  variables {
    name = "test123storage456"
  }

  assert {
    condition     = azurerm_storage_account.storage_account.name == "test123storage456"
    error_message = "Storage account name with letters and numbers should be valid"
  }
}

# Test name that starts with a number
run "starts_with_number" {
  command = plan

  variables {
    name = "1storageaccount"
  }

  assert {
    condition     = azurerm_storage_account.storage_account.name == "1storageaccount"
    error_message = "Storage account name starting with a number should be valid"
  }
}

# Test name that ends with a number
run "ends_with_number" {
  command = plan

  variables {
    name = "storageaccount1"
  }

  assert {
    condition     = azurerm_storage_account.storage_account.name == "storageaccount1"
    error_message = "Storage account name ending with a number should be valid"
  }
}