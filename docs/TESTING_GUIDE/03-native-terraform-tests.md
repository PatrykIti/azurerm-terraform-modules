# Native Terraform Tests (Unit Testing)

Native Terraform tests use the `terraform test` command to validate module logic without deploying actual infrastructure. These tests are fast, free, and provide immediate feedback during development.

## Overview

Native Terraform tests use `.tftest.hcl` files to define test scenarios with mocked providers. They are perfect for:

- ✅ Testing variable validation and constraints
- ✅ Verifying default value application
- ✅ Testing conditional resource creation logic
- ✅ Validating output formatting and structure
- ✅ Testing complex local value calculations

## Test File Structure

### Basic Test File Template

```hcl
# tests/unit/example.tftest.hcl

# Mock provider to avoid real API calls
mock_provider "azurerm" {
  mock_resource "azurerm_storage_account" {
    defaults = {
      id                       = "/subscriptions/mock/resourceGroups/mock-rg/providers/Microsoft.Storage/storageAccounts/mocksa"
      primary_blob_endpoint    = "https://mocksa.blob.core.windows.net/"
      primary_access_key       = "mock-access-key"
      primary_connection_string = "DefaultEndpointsProtocol=https;AccountName=mocksa;AccountKey=mock-key"
    }
  }
}

# Define test variables
variables {
  resource_group_name = "test-rg"
  location           = "northeurope"
}

# Test scenario
run "verify_secure_defaults" {
  command = plan

  assert {
    condition     = azurerm_storage_account.storage_account.min_tls_version == "TLS1_2"
    error_message = "Default TLS version should be TLS1_2"
  }

  assert {
    condition     = azurerm_storage_account.storage_account.enable_https_traffic_only == true
    error_message = "HTTPS traffic only should be enabled by default"
  }
}
```

### Test Commands

Native Terraform tests support different commands:

- **`plan`** - Test planning phase (most common)
- **`apply`** - Test apply phase (with mocked resources)
- **`destroy`** - Test destroy phase

## Test Categories by File

### 1. Default Values Testing (`defaults.tftest.hcl`)

Tests that verify secure defaults are properly applied:

```hcl
# tests/unit/defaults.tftest.hcl

mock_provider "azurerm" {
  mock_resource "azurerm_storage_account" {
    defaults = {
      id = "/subscriptions/mock/resourceGroups/mock-rg/providers/Microsoft.Storage/storageAccounts/mocksa"
      min_tls_version = "TLS1_2"
      enable_https_traffic_only = true
      shared_access_key_enabled = false
      infrastructure_encryption_enabled = true
    }
  }
}

variables {
  resource_group_name = "test-rg"
  location           = "northeurope"
}

# Test 1: Verify TLS defaults
run "verify_tls_defaults" {
  command = plan

  assert {
    condition     = azurerm_storage_account.storage_account.min_tls_version == "TLS1_2"
    error_message = "Default TLS version should be TLS1_2"
  }
}

# Test 2: Verify HTTPS enforcement
run "verify_https_enforcement" {
  command = plan

  assert {
    condition     = azurerm_storage_account.storage_account.enable_https_traffic_only == true
    error_message = "HTTPS traffic only should be enabled by default"
  }
}

# Test 3: Verify shared access keys disabled
run "verify_shared_keys_disabled" {
  command = plan

  assert {
    condition     = azurerm_storage_account.storage_account.shared_access_key_enabled == false
    error_message = "Shared access keys should be disabled by default"
  }
}

# Test 4: Verify infrastructure encryption
run "verify_infrastructure_encryption" {
  command = plan

  assert {
    condition     = azurerm_storage_account.storage_account.infrastructure_encryption_enabled == true
    error_message = "Infrastructure encryption should be enabled by default"
  }
}
```

### 2. Naming Convention Testing (`naming.tftest.hcl`)

Tests that validate naming logic and constraints:

```hcl
# tests/unit/naming.tftest.hcl

mock_provider "azurerm" {}

# Test 1: Basic naming
run "test_basic_naming" {
  command = plan

  variables {
    name                = "teststorage"
    resource_group_name = "test-rg"
    location           = "northeurope"
  }

  assert {
    condition     = azurerm_storage_account.storage_account.name == "teststorage"
    error_message = "Storage account name should match input"
  }
}

# Test 2: Name with suffix
run "test_naming_with_suffix" {
  command = plan

  variables {
    name                = "teststorage"
    random_suffix       = "abc123"
    resource_group_name = "test-rg"
    location           = "northeurope"
  }

  assert {
    condition     = azurerm_storage_account.storage_account.name == "teststorageabc123"
    error_message = "Storage account name should include suffix when provided"
  }
}

# Test 3: Name length validation
run "test_name_length_limits" {
  command = plan

  variables {
    name                = "verylongstorageaccountname"
    resource_group_name = "test-rg"
    location           = "northeurope"
  }

  # This should trigger validation error
  expect_failures = [
    var.name
  ]
}

# Test 4: Name character validation
run "test_name_character_validation" {
  command = plan

  variables {
    name                = "test-storage-account"  # Contains hyphens
    resource_group_name = "test-rg"
    location           = "northeurope"
  }

  expect_failures = [
    var.name
  ]
}

# Test 5: Name case sensitivity
run "test_name_case_handling" {
  command = plan

  variables {
    name                = "TestStorage"
    resource_group_name = "test-rg"
    location           = "northeurope"
  }

  assert {
    condition     = azurerm_storage_account.storage_account.name == lower("TestStorage")
    error_message = "Storage account name should be converted to lowercase"
  }
}

# Test 6: Global uniqueness handling
run "test_global_uniqueness" {
  command = plan

  variables {
    name                = "storage"
    random_suffix       = "unique123"
    resource_group_name = "test-rg"
    location           = "northeurope"
  }

  assert {
    condition     = length(azurerm_storage_account.storage_account.name) <= 24
    error_message = "Storage account name must not exceed 24 characters"
  }

  assert {
    condition     = length(azurerm_storage_account.storage_account.name) >= 3
    error_message = "Storage account name must be at least 3 characters"
  }
}
```

### 3. Output Validation Testing (`outputs.tftest.hcl`)

Tests that verify output structure and values:

```hcl
# tests/unit/outputs.tftest.hcl

mock_provider "azurerm" {
  mock_resource "azurerm_storage_account" {
    defaults = {
      id                       = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage"
      name                     = "teststorage"
      primary_blob_endpoint    = "https://teststorage.blob.core.windows.net/"
      primary_access_key       = "mock-access-key"
      primary_connection_string = "DefaultEndpointsProtocol=https;AccountName=teststorage;AccountKey=mock-key"
    }
  }
}

variables {
  name                = "teststorage"
  resource_group_name = "test-rg"
  location           = "northeurope"
}

# Test 1: ID output format
run "verify_id_output" {
  command = plan

  assert {
    condition     = output.id != ""
    error_message = "ID output should not be empty"
  }

  assert {
    condition     = can(regex("^/subscriptions/.*/resourceGroups/.*/providers/Microsoft.Storage/storageAccounts/.*", output.id))
    error_message = "ID should be a valid Azure resource ID"
  }
}

# Test 2: Name output
run "verify_name_output" {
  command = plan

  assert {
    condition     = output.name == "teststorage"
    error_message = "Name output should match the storage account name"
  }
}

# Test 3: Endpoint outputs
run "verify_endpoint_outputs" {
  command = plan

  assert {
    condition     = can(regex("^https://.*\\.blob\\.core\\.windows\\.net/$", output.primary_blob_endpoint))
    error_message = "Primary blob endpoint should be a valid HTTPS URL"
  }

  assert {
    condition     = output.primary_blob_endpoint != ""
    error_message = "Primary blob endpoint should not be empty"
  }
}

# Test 4: Sensitive outputs handling
run "verify_sensitive_outputs" {
  command = plan

  # Access key should be marked as sensitive
  assert {
    condition     = output.primary_access_key != ""
    error_message = "Primary access key should be available in output"
  }
}

# Test 5: Connection string format
run "verify_connection_string_format" {
  command = plan

  assert {
    condition     = can(regex("^DefaultEndpointsProtocol=https;AccountName=.*;AccountKey=.*", output.primary_connection_string))
    error_message = "Connection string should have correct format"
  }
}
```

### 4. Variable Validation Testing (`validation.tftest.hcl`)

Tests that verify input validation rules work correctly:

```hcl
# tests/unit/validation.tftest.hcl

mock_provider "azurerm" {}

# Test 1: Valid storage account name
run "valid_storage_account_name" {
  command = plan

  variables {
    name                = "validstorageaccount"
    resource_group_name = "test-rg"
    location           = "northeurope"
  }

  # Should succeed without errors
}

# Test 2: Invalid name - too short
run "invalid_name_too_short" {
  command = plan

  variables {
    name                = "ab"  # Too short
    resource_group_name = "test-rg"
    location           = "northeurope"
  }

  expect_failures = [
    var.name
  ]
}

# Test 3: Invalid name - too long
run "invalid_name_too_long" {
  command = plan

  variables {
    name                = "verylongstorageaccountnamethatexceedslimit"  # Too long
    resource_group_name = "test-rg"
    location           = "northeurope"
  }

  expect_failures = [
    var.name
  ]
}

# Test 4: Invalid name - special characters
run "invalid_name_special_chars" {
  command = plan

  variables {
    name                = "test-storage-account"  # Contains hyphens
    resource_group_name = "test-rg"
    location           = "northeurope"
  }

  expect_failures = [
    var.name
  ]
}

# Test 5: Invalid name - uppercase
run "invalid_name_uppercase" {
  command = plan

  variables {
    name                = "TestStorageAccount"  # Contains uppercase
    resource_group_name = "test-rg"
    location           = "northeurope"
  }

  expect_failures = [
    var.name
  ]
}

# Test 6: Valid account tier
run "valid_account_tier" {
  command = plan

  variables {
    name                = "teststorage"
    resource_group_name = "test-rg"
    location           = "northeurope"
    account_tier        = "Standard"
  }

  # Should succeed
}

# Test 7: Invalid account tier
run "invalid_account_tier" {
  command = plan

  variables {
    name                = "teststorage"
    resource_group_name = "test-rg"
    location           = "northeurope"
    account_tier        = "InvalidTier"
  }

  expect_failures = [
    var.account_tier
  ]
}

# Test 8: Valid replication type
run "valid_replication_type" {
  command = plan

  variables {
    name                     = "teststorage"
    resource_group_name      = "test-rg"
    location                = "northeurope"
    account_replication_type = "LRS"
  }

  # Should succeed
}

# Test 9: Invalid replication type
run "invalid_replication_type" {
  command = plan

  variables {
    name                     = "teststorage"
    resource_group_name      = "test-rg"
    location                = "northeurope"
    account_replication_type = "INVALID"
  }

  expect_failures = [
    var.account_replication_type
  ]
}

# Test 10: Valid location
run "valid_location" {
  command = plan

  variables {
    name                = "teststorage"
    resource_group_name = "test-rg"
    location           = "northeurope"
  }

  # Should succeed
}

# Test 11: Container access type validation
run "valid_container_access_type" {
  command = plan

  variables {
    name                = "teststorage"
    resource_group_name = "test-rg"
    location           = "northeurope"
    containers = [
      {
        name                  = "testcontainer"
        container_access_type = "private"
      }
    ]
  }

  # Should succeed
}

# Test 12: Invalid container access type
run "invalid_container_access_type" {
  command = plan

  variables {
    name                = "teststorage"
    resource_group_name = "test-rg"
    location           = "northeurope"
    containers = [
      {
        name                  = "testcontainer"
        container_access_type = "invalid"
      }
    ]
  }

  expect_failures = [
    var.containers
  ]
}

# Test 13: Network rules validation
run "valid_network_rules" {
  command = plan

  variables {
    name                = "teststorage"
    resource_group_name = "test-rg"
    location           = "northeurope"
    network_rules = {
      default_action = "Deny"
      ip_rules      = ["203.0.113.0/24"]
      bypass        = "AzureServices"
    }
  }

  # Should succeed
}

# Test 14: Invalid network default action
run "invalid_network_default_action" {
  command = plan

  variables {
    name                = "teststorage"
    resource_group_name = "test-rg"
    location           = "northeurope"
    network_rules = {
      default_action = "Invalid"
      ip_rules      = ["203.0.113.0/24"]
      bypass        = "AzureServices"
    }
  }

  expect_failures = [
    var.network_rules
  ]
}
```

### 5. Conditional Logic Testing (`containers.tftest.hcl`)

Tests that verify conditional resource creation works correctly:

```hcl
# tests/unit/containers.tftest.hcl

mock_provider "azurerm" {
  mock_resource "azurerm_storage_container" {
    defaults = {
      id                    = "/subscriptions/mock/resourceGroups/mock-rg/providers/Microsoft.Storage/storageAccounts/mocksa/blobServices/default/containers/mockcontainer"
      name                  = "mockcontainer"
      container_access_type = "private"
    }
  }
}

variables {
  name                = "teststorage"
  resource_group_name = "test-rg"
  location           = "northeurope"
}

# Test 1: No containers by default
run "no_containers_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_storage_container.containers) == 0
    error_message = "No containers should be created by default"
  }
}

# Test 2: Single container creation
run "single_container_creation" {
  command = plan

  variables {
    containers = [
      {
        name                  = "testcontainer"
        container_access_type = "private"
      }
    ]
  }

  assert {
    condition     = length(azurerm_storage_container.containers) == 1
    error_message = "Should create exactly one container"
  }

  assert {
    condition     = azurerm_storage_container.containers["testcontainer"].name == "testcontainer"
    error_message = "Container name should match input"
  }

  assert {
    condition     = azurerm_storage_container.containers["testcontainer"].container_access_type == "private"
    error_message = "Container access type should match input"
  }
}

# Test 3: Multiple containers creation
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
      },
      {
        name                  = "container3"
        container_access_type = "container"
      }
    ]
  }

  assert {
    condition     = length(azurerm_storage_container.containers) == 3
    error_message = "Should create exactly three containers"
  }

  assert {
    condition     = azurerm_storage_container.containers["container1"].container_access_type == "private"
    error_message = "Container1 should have private access"
  }

  assert {
    condition     = azurerm_storage_container.containers["container2"].container_access_type == "blob"
    error_message = "Container2 should have blob access"
  }

  assert {
    condition     = azurerm_storage_container.containers["container3"].container_access_type == "container"
    error_message = "Container3 should have container access"
  }
}

# Test 4: Container dependencies
run "container_dependencies" {
  command = plan

  variables {
    containers = [
      {
        name                  = "testcontainer"
        container_access_type = "private"
      }
    ]
  }

  # Verify container depends on storage account
  assert {
    condition     = azurerm_storage_container.containers["testcontainer"].storage_account_name == azurerm_storage_account.storage_account.name
    error_message = "Container should reference storage account name"
  }
}

# Test 5: Container naming validation
run "container_naming_validation" {
  command = plan

  variables {
    containers = [
      {
        name                  = "valid-container-name"
        container_access_type = "private"
      }
    ]
  }

  # Should succeed with valid container name
}

# Test 6: Empty containers list
run "empty_containers_list" {
  command = plan

  variables {
    containers = []
  }

  assert {
    condition     = length(azurerm_storage_container.containers) == 0
    error_message = "Empty containers list should create no containers"
  }
}

# Test 7: Container with metadata
run "container_with_metadata" {
  command = plan

  variables {
    containers = [
      {
        name                  = "testcontainer"
        container_access_type = "private"
        metadata = {
          environment = "test"
          purpose     = "testing"
        }
      }
    ]
  }

  assert {
    condition     = azurerm_storage_container.containers["testcontainer"].metadata["environment"] == "test"
    error_message = "Container metadata should be preserved"
  }
}
```

## Running Native Terraform Tests

### Basic Execution

```bash
# Run all unit tests
cd modules/azurerm_storage_account
terraform test

# Run specific test file
terraform test -test-directory=tests/unit tests/unit/defaults.tftest.hcl

# Run with verbose output
terraform test -verbose

# Run tests in specific directory
terraform test -test-directory=tests/unit
```

### Test Output Examples

#### Successful Test Run
```
tests/unit/defaults.tftest.hcl... in progress
  run "verify_tls_defaults"... pass
  run "verify_https_enforcement"... pass
  run "verify_shared_keys_disabled"... pass
  run "verify_infrastructure_encryption"... pass
tests/unit/defaults.tftest.hcl... pass

tests/unit/validation.tftest.hcl... in progress
  run "valid_storage_account_name"... pass
  run "invalid_name_too_short"... pass
  run "invalid_name_too_long"... pass
tests/unit/validation.tftest.hcl... pass

Success! 7 passed, 0 failed.
```

#### Failed Test Run
```
tests/unit/defaults.tftest.hcl... in progress
  run "verify_tls_defaults"... pass
  run "verify_https_enforcement"... fail

Error: Test assertion failed

  on tests/unit/defaults.tftest.hcl line 25, in run "verify_https_enforcement":
  25:     condition     = azurerm_storage_account.storage_account.enable_https_traffic_only == true
      ├────────────────
      │ azurerm_storage_account.storage_account.enable_https_traffic_only is false

HTTPS traffic only should be enabled by default

tests/unit/defaults.tftest.hcl... fail

Failure! 1 passed, 1 failed.
```

## Best Practices for Native Tests

### 1. Mock Provider Configuration

Always mock the Azure provider to avoid real API calls:

```hcl
mock_provider "azurerm" {
  mock_resource "azurerm_storage_account" {
    defaults = {
      # Provide realistic mock values
      id = "/subscriptions/mock/resourceGroups/mock-rg/providers/Microsoft.Storage/storageAccounts/mocksa"
      # Include all attributes your tests will reference
    }
  }
  
  # Mock additional resources as needed
  mock_resource "azurerm_storage_container" {
    defaults = {
      id = "/subscriptions/mock/resourceGroups/mock-rg/providers/Microsoft.Storage/storageAccounts/mocksa/blobServices/default/containers/mockcontainer"
    }
  }
}
```

### 2. Comprehensive Assertions

Write clear, specific assertions with helpful error messages:

```hcl
assert {
  condition     = azurerm_storage_account.storage_account.min_tls_version == "TLS1_2"
  error_message = "Default TLS version should be TLS1_2 for security compliance"
}

assert {
  condition     = length(azurerm_storage_account.storage_account.name) >= 3 && length(azurerm_storage_account.storage_account.name) <= 24
  error_message = "Storage account name must be between 3 and 24 characters (current: ${length(azurerm_storage_account.storage_account.name)})"
}
```

### 3. Test Organization

Organize tests logically within files:

```hcl
# Group related tests together
run "verify_security_defaults" { }
run "verify_encryption_settings" { }
run "verify_access_controls" { }

# Separate positive and negative tests
run "valid_configuration" { }
run "invalid_configuration" {
  expect_failures = [var.some_variable]
}
```

### 4. Variable Management

Use consistent variable patterns across tests:

```hcl
# Standard variables for all tests
variables {
  name                = "teststorage"
  resource_group_name = "test-rg"
  location           = "northeurope"
}

# Override specific variables per test
run "test_with_custom_tier" {
  variables {
    account_tier = "Premium"
  }
  
  # Test implementation
}
```

### 5. Error Testing

Test validation rules thoroughly:

```hcl
# Test each validation rule separately
run "invalid_name_too_short" {
  variables {
    name = "ab"  # Specific invalid case
  }
  
  expect_failures = [var.name]
}

run "invalid_name_special_chars" {
  variables {
    name = "test-storage"  # Different invalid case
  }
  
  expect_failures = [var.name]
}
```

## Integration with CI/CD

### GitHub Actions Integration

```yaml
name: Unit Tests

on:
  push:
    paths:
      - 'modules/*/tests/unit/**'
      - 'modules/*/*.tf'

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        module: [storage_account, virtual_network, key_vault]
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.9.0
      
      - name: Run Unit Tests
        run: |
          cd modules/azurerm_${{ matrix.module }}
          terraform init
          terraform test -test-directory=tests/unit
```

### Pre-commit Hook

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: terraform-test
        name: Terraform Unit Tests
        entry: bash -c 'cd modules/azurerm_storage_account && terraform test -test-directory=tests/unit'
        language: system
        files: \.(tf|tftest\.hcl)$
        pass_filenames: false
```

## Next Steps

Now that you understand native Terraform tests, proceed to:

1. **[Variable Validation Testing](04-variable-validation.md)** - Deep dive into input validation
2. **[Terratest Framework](05-terratest-framework.md)** - Learn integration testing
3. **[Test Helpers & Utilities](07-test-helpers.md)** - Shared testing utilities

---

**Key Takeaways**:
- Native tests are fast, free, and provide immediate feedback
- Use mocked providers to avoid real infrastructure costs
- Organize tests by feature and purpose in separate files
- Write comprehensive assertions with clear error messages
- Test both positive and negative scenarios thoroughly
- Integrate unit tests into CI/CD for continuous validation
