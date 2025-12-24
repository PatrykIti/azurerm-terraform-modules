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
  mock_resource "azurerm_kubernetes_cluster" {
    defaults = {
      id   = "/subscriptions/mock/resourceGroups/mock-rg/providers/Microsoft.ContainerService/managedClusters/test-aks"
      name = "test-aks"
    }
  }
}

# Define test variables
variables {
  name                = "test-aks"
  resource_group_name = "test-rg"
  location           = "northeurope"
  dns_config = {
    dns_prefix = "testaks"
  }
  default_node_pool = {
    name       = "default"
    vm_size    = "Standard_D2_v2"
    node_count = 1
  }
  network_profile = {
    network_plugin = "azure"
  }
}

# Test scenario
run "verify_default_identity" {
  command = plan

  assert {
    condition     = azurerm_kubernetes_cluster.kubernetes_cluster.identity[0].type == "SystemAssigned"
    error_message = "Default identity type should be SystemAssigned"
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
  mock_resource "azurerm_kubernetes_cluster" {
    defaults = {
      id   = "/subscriptions/mock/resourceGroups/mock-rg/providers/Microsoft.ContainerService/managedClusters/test-aks"
      name = "test-aks"
    }
  }
}

variables {
  name                = "test-aks"
  resource_group_name = "test-rg"
  location           = "northeurope"
  dns_config = {
    dns_prefix = "testaks"
  }
  default_node_pool = {
    name       = "default"
    vm_size    = "Standard_D2_v2"
    node_count = 1
  }
  network_profile = {
    network_plugin = "azure"
  }
}

# Test 1: Verify default identity
run "verify_default_identity" {
  command = plan

  assert {
    condition     = azurerm_kubernetes_cluster.kubernetes_cluster.identity[0].type == "SystemAssigned"
    error_message = "Default identity type should be SystemAssigned"
  }
}

# Test 2: Verify default SKU
run "verify_default_sku" {
  command = plan

  assert {
    condition     = azurerm_kubernetes_cluster.kubernetes_cluster.sku_tier == "Free"
    error_message = "Default SKU tier should be Free"
  }
}

# Test 3: Verify default network profile
run "verify_default_network_profile" {
  command = plan

  assert {
    condition     = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].network_plugin == "azure"
    error_message = "Default network plugin should be azure"
  }
  assert {
    condition     = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].load_balancer_sku == "standard"
    error_message = "Default load balancer SKU should be standard"
  }
}

# Test 4: Verify default feature flags
run "verify_default_features" {
  command = plan

  assert {
    condition     = azurerm_kubernetes_cluster.kubernetes_cluster.azure_policy_enabled == false
    error_message = "Azure Policy should be disabled by default"
  }
  assert {
    condition     = azurerm_kubernetes_cluster.kubernetes_cluster.workload_identity_enabled == false
    error_message = "Workload Identity should be disabled by default"
  }
}
```

### 2. Naming Convention Testing (`naming.tftest.hcl`)

Tests that validate naming logic and constraints:

```hcl
# tests/unit/naming.tftest.hcl

mock_provider "azurerm" {
  mock_resource "azurerm_kubernetes_cluster" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ContainerService/managedClusters/test-aks"
      name = "test-aks"
    }
  }
}

variables {
  resource_group_name = "test-rg"
  location            = "northeurope"
  default_node_pool = {
    name       = "default"
    vm_size    = "Standard_D2_v2"
    node_count = 1
  }
}

# Test 1: Valid dns_prefix
run "valid_dns_prefix" {
  command = plan

  variables {
    name = "validakscluster"
    dns_config = {
      dns_prefix = "validdnsprefix"
    }
  }

  assert {
    condition     = azurerm_kubernetes_cluster.kubernetes_cluster.dns_prefix == "validdnsprefix"
    error_message = "DNS prefix should be set correctly"
  }
}

# Test 2: Valid dns_prefix_private_cluster
run "valid_dns_prefix_private_cluster" {
  command = plan

  variables {
    name = "validakscluster"
    dns_config = {
      dns_prefix_private_cluster = "validprivateprefix"
    }
    private_cluster_config = {
      private_cluster_enabled = true
    }
  }

  assert {
    condition     = azurerm_kubernetes_cluster.kubernetes_cluster.dns_prefix_private_cluster == "validprivateprefix"
    error_message = "Private DNS prefix should be set correctly"
  }
}
```

### 3. Output Validation Testing (`outputs.tftest.hcl`)

Tests that verify output structure and values:

```hcl
# tests/unit/outputs.tftest.hcl

mock_provider "azurerm" {
  mock_resource "azurerm_kubernetes_cluster" {
    defaults = {
      id   = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.ContainerService/managedClusters/test-aks"
      name = "test-aks"
    }
  }
}

variables {
  name                = "test-aks"
  resource_group_name = "test-rg"
  location           = "northeurope"
  dns_config = {
    dns_prefix = "testaks"
  }
  default_node_pool = {
    name       = "default"
    vm_size    = "Standard_D2_v2"
    node_count = 1
  }
  network_profile = {
    network_plugin = "azure"
  }
}

# Test 1: ID output format
run "verify_id_output" {
  command = plan

  assert {
    condition     = output.id != ""
    error_message = "ID output should not be empty"
  }

  assert {
    condition     = can(regex("^/subscriptions/.*/resourceGroups/.*/providers/Microsoft.ContainerService/managedClusters/.*", output.id))
    error_message = "ID should be a valid Azure resource ID"
  }
}

# Test 2: Name output
run "verify_name_output" {
  command = plan

  assert {
    condition     = output.name == "test-aks"
    error_message = "Name output should match the cluster name"
  }
}

# Test 3: Resource group output
run "verify_resource_group_output" {
  command = plan

  assert {
    condition     = output.resource_group_name == "test-rg"
    error_message = "Resource group output should match input"
  }
}
```

### 4. Variable Validation Testing (`validation.tftest.hcl`)

Tests that verify input validation rules work correctly:

```hcl
# tests/unit/validation.tftest.hcl

mock_provider "azurerm" {
  mock_resource "azurerm_kubernetes_cluster" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ContainerService/managedClusters/test-aks"
      name = "test-aks"
    }
  }
}

variables {
  resource_group_name = "test-rg"
  location            = "northeurope"
  default_node_pool = {
    name       = "default"
    vm_size    = "Standard_D2_v2"
    node_count = 1
  }
}

# Test 1: Invalid name - uppercase
run "invalid_name_uppercase" {
  command = plan

  variables {
    name = "InvalidAKSName"
  }

  expect_failures = [
    var.name,
  ]
}

# Test 2: Invalid name - special characters
run "invalid_name_special_chars" {
  command = plan

  variables {
    name = "invalid_aks_name"
  }

  expect_failures = [
    var.name,
  ]
}

# Test 3: Missing dns_prefix/dns_prefix_private_cluster
run "missing_dns_prefix" {
  command = plan

  variables {
    name       = "validname"
    dns_config = {}
  }

  expect_failures = [
    var.dns_config,
  ]
}

# Test 4: Both dns_prefix and dns_prefix_private_cluster set
run "both_dns_prefixes_set" {
  command = plan

  variables {
    name = "validname"
    dns_config = {
      dns_prefix                 = "publicprefix"
      dns_prefix_private_cluster = "privateprefix"
    }
  }

  expect_failures = [
    var.dns_config,
  ]
}

# Test 5: Diagnostic settings missing destination
run "diagnostic_settings_missing_destination" {
  command = plan

  variables {
    name = "validname"
    diagnostic_settings = [
      {
        name  = "missing-destination"
        areas = ["api_plane"]
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings,
  ]
}
```

### 5. Conditional Logic Testing (`node_pools.tftest.hcl`)

Tests that verify conditional resource creation works correctly:

```hcl
# tests/unit/node_pools.tftest.hcl

mock_provider "azurerm" {
  mock_resource "azurerm_kubernetes_cluster" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ContainerService/managedClusters/test-aks"
      name = "test-aks"
    }
  }
  mock_resource "azurerm_kubernetes_cluster_node_pool" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ContainerService/managedClusters/test-aks/agentPools/testpool"
      name = "testpool"
    }
  }
}

variables {
  name                = "akstestcluster"
  resource_group_name = "test-rg"
  location           = "northeurope"
  dns_config = {
    dns_prefix = "akstest"
  }
  default_node_pool = {
    name       = "default"
    vm_size    = "Standard_D2_v2"
    node_count = 1
  }
}

# Test 1: No additional node pools by default
run "no_additional_node_pools_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_kubernetes_cluster_node_pool.kubernetes_cluster_node_pool) == 0
    error_message = "No additional node pools should be created when node_pools is not set"
  }
}

# Test 2: Single additional node pool
run "single_additional_node_pool" {
  command = plan

  variables {
    node_pools = [
      {
        name       = "userpool1"
        vm_size    = "Standard_D2_v2"
        node_count = 2
      }
    ]
  }

  assert {
    condition     = length(azurerm_kubernetes_cluster_node_pool.kubernetes_cluster_node_pool) == 1
    error_message = "Should create exactly one additional node pool"
  }

  assert {
    condition     = azurerm_kubernetes_cluster_node_pool.kubernetes_cluster_node_pool["userpool1"].name == "userpool1"
    error_message = "Node pool name should match input"
  }

  assert {
    condition     = azurerm_kubernetes_cluster_node_pool.kubernetes_cluster_node_pool["userpool1"].node_count == 2
    error_message = "Node count for the additional node pool should be 2"
  }
}

# Test 3: Multiple additional node pools
run "multiple_additional_node_pools" {
  command = plan

  variables {
    node_pools = [
      {
        name       = "userpool1"
        vm_size    = "Standard_D2_v2"
        node_count = 1
      },
      {
        name       = "userpool2"
        vm_size    = "Standard_D4_v3"
        node_count = 3
      }
    ]
  }

  assert {
    condition     = length(azurerm_kubernetes_cluster_node_pool.kubernetes_cluster_node_pool) == 2
    error_message = "Should create exactly two additional node pools"
  }

  assert {
    condition     = azurerm_kubernetes_cluster_node_pool.kubernetes_cluster_node_pool["userpool2"].vm_size == "Standard_D4_v3"
    error_message = "VM size for the second node pool should be correct"
  }
}
```

## Running Native Terraform Tests

### Basic Execution

```bash
# Run all unit tests
cd modules/azurerm_kubernetes_cluster
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
  run "verify_default_identity"... pass
  run "verify_default_sku"... pass
  run "verify_default_network_profile"... pass
  run "verify_default_features"... pass
tests/unit/defaults.tftest.hcl... pass

tests/unit/validation.tftest.hcl... in progress
  run "invalid_name_uppercase"... pass
  run "invalid_name_special_chars"... pass
  run "missing_dns_prefix"... pass
  run "both_dns_prefixes_set"... pass
tests/unit/validation.tftest.hcl... pass

Success! 8 passed, 0 failed.
```

#### Failed Test Run
```
tests/unit/defaults.tftest.hcl... in progress
  run "verify_default_identity"... pass
  run "verify_default_network_profile"... fail

Error: Test assertion failed

  on tests/unit/defaults.tftest.hcl line 35, in run "verify_default_network_profile":
  35:     condition     = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].network_plugin == "azure"
      ├────────────────
      │ azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].network_plugin is "kubenet"

Default network plugin should be azure

tests/unit/defaults.tftest.hcl... fail

Failure! 1 passed, 1 failed.
```

## Best Practices for Native Tests

### 1. Mock Provider Configuration

Always mock the Azure provider to avoid real API calls:

```hcl
mock_provider "azurerm" {
  mock_resource "azurerm_kubernetes_cluster" {
    defaults = {
      # Provide realistic mock values
      id = "/subscriptions/mock/resourceGroups/mock-rg/providers/Microsoft.ContainerService/managedClusters/test-aks"
      # Include all attributes your tests will reference
    }
  }
  
  # Mock additional resources as needed
  mock_resource "azurerm_kubernetes_cluster_node_pool" {
    defaults = {
      id = "/subscriptions/mock/resourceGroups/mock-rg/providers/Microsoft.ContainerService/managedClusters/test-aks/agentPools/testpool"
    }
  }
}
```

### 2. Comprehensive Assertions

Write clear, specific assertions with helpful error messages:

```hcl
assert {
  condition     = azurerm_kubernetes_cluster.kubernetes_cluster.identity[0].type == "SystemAssigned"
  error_message = "Default identity type should be SystemAssigned for security compliance"
}

assert {
  condition     = can(regex("^[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$", var.name))
  error_message = "Cluster name must follow AKS naming rules"
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
  name                = "test-aks"
  resource_group_name = "test-rg"
  location           = "northeurope"
  dns_config = {
    dns_prefix = "testaks"
  }
  default_node_pool = {
    name       = "default"
    vm_size    = "Standard_D2_v2"
    node_count = 1
  }
}

# Override specific variables per test
run "test_with_custom_sku" {
  variables {
    sku_config = {
      sku_tier = "Standard"
    }
  }
  
  # Test implementation
}
```

### 5. Error Testing

Test validation rules thoroughly:

```hcl
# Test each validation rule separately
run "invalid_name_uppercase" {
  variables {
    name = "InvalidAKSName"
  }
  
  expect_failures = [var.name]
}

run "invalid_name_special_chars" {
  variables {
    name = "invalid_aks_name"
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
        module: [kubernetes_cluster, virtual_network, key_vault]
    
    steps:
      - uses: actions/checkout@v5
      
      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.12.2
      
      - name: Run Unit Tests
        run: |
          cd modules/azurerm_${{ matrix.module }}
          terraform init
          terraform test -test-directory=tests/unit
```

### Pre-commit Hook (Optional)

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: terraform-test
        name: Terraform Unit Tests
        entry: bash -c 'cd modules/azurerm_kubernetes_cluster && terraform test -test-directory=tests/unit'
        language: system
        files: \.(tf|tftest\.hcl)$
        pass_filenames: false
```

## Next Steps

Now that you understand native Terraform tests, proceed to:

1. **[Terratest Integration Overview](04-terratest-integration-overview.md)** - Learn integration testing
2. **[Terratest Go File Structure](05-terratest-file-structure.md)** - Structure your Go tests
3. **[Helper Pattern & Validation](06-terratest-helpers-and-validation.md)** - Shared testing utilities

---

**Key Takeaways**:
- Native tests are fast, free, and provide immediate feedback
- Use mocked providers to avoid real infrastructure costs
- Organize tests by feature and purpose in separate files
- Write comprehensive assertions with clear error messages
- Test both positive and negative scenarios thoroughly
- Integrate unit tests into CI/CD for continuous validation
