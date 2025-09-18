# Test conditional logic for containers in Storage Account module

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
  name                = "testsa"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

# Test no containers created by default
run "no_containers_by_default" {
  command = plan

  # Verify that no containers are created when not specified
  assert {
    condition     = length(azurerm_storage_container.storage_container) == 0
    error_message = "No containers should be created when containers variable is not set"
  }
}

# Test single container creation
run "single_container_creation" {
  command = plan

  variables {
    containers = [
      {
        name                  = "container1"
        container_access_type = "private"
      }
    ]
  }

  # Verify correct number of containers
  assert {
    condition     = length(azurerm_storage_container.storage_container) == 1
    error_message = "Should create exactly 1 container"
  }

  # Verify container properties
  assert {
    condition     = azurerm_storage_container.storage_container["container1"].name == "container1"
    error_message = "Container name should match input"
  }

  assert {
    condition     = azurerm_storage_container.storage_container["container1"].container_access_type == "private"
    error_message = "Container access type should be private"
  }
}

# Test multiple containers creation
run "multiple_containers_creation" {
  command = plan

  variables {
    containers = [
      {
        name                  = "container1"
        container_access_type = "private"
      },
      {
        name                  = "container2"
        container_access_type = "blob"
        metadata = {
          environment = "test"
          purpose     = "storage"
        }
      },
      {
        name                  = "container3"
        container_access_type = "container"
      }
    ]
  }

  # Verify correct number of containers
  assert {
    condition     = length(azurerm_storage_container.storage_container) == 3
    error_message = "Should create exactly 3 containers"
  }

  # Verify first container
  assert {
    condition     = azurerm_storage_container.storage_container["container1"].name == "container1"
    error_message = "Container1 name should match"
  }

  assert {
    condition     = azurerm_storage_container.storage_container["container1"].container_access_type == "private"
    error_message = "Container1 access type should be private"
  }

  # Verify second container
  assert {
    condition     = azurerm_storage_container.storage_container["container2"].name == "container2"
    error_message = "Container2 name should match"
  }

  assert {
    condition     = azurerm_storage_container.storage_container["container2"].container_access_type == "blob"
    error_message = "Container2 access type should be blob"
  }

  assert {
    condition     = azurerm_storage_container.storage_container["container2"].metadata["environment"] == "test"
    error_message = "Container2 metadata environment should be test"
  }

  assert {
    condition     = azurerm_storage_container.storage_container["container2"].metadata["purpose"] == "storage"
    error_message = "Container2 metadata purpose should be storage"
  }

  # Verify third container
  assert {
    condition     = azurerm_storage_container.storage_container["container3"].name == "container3"
    error_message = "Container3 name should match"
  }

  assert {
    condition     = azurerm_storage_container.storage_container["container3"].container_access_type == "container"
    error_message = "Container3 access type should be container"
  }
}

# Test container with default access type
run "container_default_access_type" {
  command = plan

  variables {
    containers = [
      {
        name = "defaultcontainer"
        # container_access_type not specified, should use default "private"
      }
    ]
  }

  # Verify default access type
  assert {
    condition     = azurerm_storage_container.storage_container["defaultcontainer"].container_access_type == "private"
    error_message = "Container should use default access type of private when not specified"
  }
}

# Test container dependency on storage account
run "container_depends_on_storage_account" {
  command = plan

  variables {
    containers = [
      {
        name                  = "testcontainer"
        container_access_type = "private"
      }
    ]
  }

  # Verify container is created
  assert {
    condition     = length(azurerm_storage_container.storage_container) == 1
    error_message = "Container should be created successfully"
  }

  # Verify container has correct name
  assert {
    condition     = azurerm_storage_container.storage_container["testcontainer"].name == "testcontainer"
    error_message = "Container name should be correct"
  }
}

# Test empty containers list
run "empty_containers_list" {
  command = plan

  variables {
    containers = []
  }

  # Verify no containers are created with empty list
  assert {
    condition     = length(azurerm_storage_container.storage_container) == 0
    error_message = "No containers should be created with empty list"
  }
}

# Test containers with only metadata
run "containers_with_metadata_only" {
  command = plan

  variables {
    containers = [
      {
        name = "metadatacontainer"
        metadata = {
          project     = "test-project"
          environment = "dev"
          owner       = "team-a"
        }
      }
    ]
  }

  # Verify metadata is set correctly
  assert {
    condition     = azurerm_storage_container.storage_container["metadatacontainer"].metadata["project"] == "test-project"
    error_message = "Container metadata project should be set"
  }

  assert {
    condition     = azurerm_storage_container.storage_container["metadatacontainer"].metadata["environment"] == "dev"
    error_message = "Container metadata environment should be set"
  }

  assert {
    condition     = azurerm_storage_container.storage_container["metadatacontainer"].metadata["owner"] == "team-a"
    error_message = "Container metadata owner should be set"
  }
}