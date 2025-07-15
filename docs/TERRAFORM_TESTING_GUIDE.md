# Terraform Azure Modules - Testing Guide

This comprehensive guide outlines the testing strategies, patterns, and best practices for testing Terraform modules in this repository. We employ a hybrid approach combining native Terraform tests (HCL) for unit testing and Terratest (Go) for integration testing.

## Table of Contents

1. [Testing Philosophy](#testing-philosophy)
2. [Testing Pyramid](#testing-pyramid)
3. [Unit Testing with Native Terraform Tests](#unit-testing-with-native-terraform-tests)
4. [Integration Testing with Terratest](#integration-testing-with-terratest)
5. [End-to-End Testing](#end-to-end-testing)
6. [Security and Compliance Testing](#security-and-compliance-testing)
7. [Performance Testing](#performance-testing)
8. [Mock Strategies](#mock-strategies)
9. [CI/CD Integration](#cicd-integration)
10. [Test Organization](#test-organization)
11. [Best Practices](#best-practices)
12. [Common Patterns](#common-patterns)

## Testing Philosophy

Our testing approach follows these principles:

1. **Test at Multiple Levels** - From fast unit tests to comprehensive integration tests
2. **Fail Fast** - Catch issues early with static analysis and unit tests
3. **Test Real Infrastructure** - Validate actual Azure resource deployment and configuration
4. **Cost Conscious** - Use mocking and minimal SKUs where appropriate
5. **Security First** - Embed security scanning throughout the testing pipeline

## Testing Pyramid

### Level 1: Static Analysis (Fast & Free)
- **Tools**: `terraform validate`, `terraform fmt`, `tflint`, `checkov`, `tfsec`
- **When**: On every commit, pre-commit hooks
- **Duration**: < 30 seconds
- **Cost**: Free

### Level 2: Unit Tests (Fast & Free)
- **Tools**: Native Terraform Test (`terraform test`)
- **When**: On every push
- **Duration**: < 2 minutes
- **Cost**: Free (uses mocked providers)

### Level 3: Integration Tests (Slower & Costs Money)
- **Tools**: Terratest with Go
- **When**: On pull requests
- **Duration**: 5-30 minutes per module
- **Cost**: Minimal (uses cheapest SKUs)

### Level 4: End-to-End Tests (Slowest & Most Expensive)
- **Tools**: Terratest with multi-module compositions
- **When**: Nightly or before releases
- **Duration**: 30-60 minutes
- **Cost**: Higher (tests full stack)

## Unit Testing with Native Terraform Tests

Native Terraform tests (`.tftest.hcl` files) are perfect for testing module logic without deploying infrastructure.

### When to Use Native Tests

✅ Testing variable validation and defaults
✅ Verifying output formatting
✅ Testing conditional resource creation
✅ Validating complex locals and expressions
✅ Quick feedback during development

### Directory Structure

```
modules/azurerm_storage_account/
├── tests/
│   ├── unit/
│   │   ├── defaults.tftest.hcl
│   │   ├── naming.tftest.hcl
│   │   ├── outputs.tftest.hcl
│   │   └── validation.tftest.hcl
│   └── integration/
│       └── storage_account_test.go
```

### Example: Testing with Mock Provider

```hcl
# modules/azurerm_storage_account/tests/unit/defaults.tftest.hcl

# Mock the Azure provider to avoid real API calls
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

variables {
  resource_group_name = "test-rg"
  location           = "northeurope"
}

# Test default security settings
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

  assert {
    condition     = azurerm_storage_account.storage_account.shared_access_key_enabled == false
    error_message = "Shared access keys should be disabled by default"
  }
}
```

### Example: Testing Conditional Logic

```hcl
# modules/azurerm_storage_account/tests/unit/containers.tftest.hcl

mock_provider "azurerm" {}

variables {
  resource_group_name = "test-rg"
  location           = "northeurope"
  
  containers = [
    {
      name                  = "container1"
      container_access_type = "private"
    },
    {
      name                  = "container2"
      container_access_type = "blob"
    }
  ]
}

run "containers_created_correctly" {
  command = plan

  # Verify correct number of containers
  assert {
    condition     = length(azurerm_storage_container.containers) == 2
    error_message = "Should create exactly 2 containers"
  }

  # Verify container names
  assert {
    condition     = azurerm_storage_container.containers["container1"].name == "container1"
    error_message = "Container1 name mismatch"
  }

  assert {
    condition     = azurerm_storage_container.containers["container2"].container_access_type == "blob"
    error_message = "Container2 access type should be blob"
  }
}
```

### Testing Variable Validation

```hcl
# modules/azurerm_storage_account/tests/unit/validation.tftest.hcl

run "invalid_storage_account_name_too_short" {
  command = plan

  variables {
    storage_account_name = "ab"  # Too short
    resource_group_name  = "test-rg"
    location            = "northeurope"
  }

  expect_failures = [
    var.storage_account_name,
  ]
}

run "invalid_storage_account_name_special_chars" {
  command = plan

  variables {
    storage_account_name = "test-storage-account"  # Contains hyphens
    resource_group_name  = "test-rg"
    location            = "northeurope"
  }

  expect_failures = [
    var.storage_account_name,
  ]
}
```

## Integration Testing with Terratest

Terratest provides the ability to deploy real infrastructure and validate its configuration using Go.

### When to Use Terratest

✅ Verifying resources are created with correct properties
✅ Testing network connectivity and security rules
✅ Validating IAM permissions work as expected
✅ Testing interactions between resources
✅ Ensuring Azure Policy compliance

### Test File Organization

Our Terratest implementation follows a specific structure that separates concerns and improves maintainability:

#### 1. Main Test File (`virtual_network_test.go`)
The main test file contains the primary test orchestration:

```go
// TestVirtualNetworkModule runs all Virtual Network module tests
func TestVirtualNetworkModule(t *testing.T) {
    t.Parallel()

    // Run subtests - each maps to a fixture directory
    t.Run("Basic", TestVirtualNetworkBasic)
    t.Run("Complete", TestVirtualNetworkComplete)
    t.Run("Secure", TestVirtualNetworkSecure)
    t.Run("Network", TestVirtualNetworkNetwork)
    t.Run("PrivateEndpoint", TestVirtualNetworkPrivateEndpointBasic)
}
```

Key characteristics:
- Each test function name starts with `Test` for Go test discovery
- Tests use `t.Parallel()` for concurrent execution
- Each test maps to a specific fixture in the `fixtures/` directory
- Tests follow the pattern: Deploy → Validate → Cleanup

#### 2. Integration Test File (`integration_test.go`)
Contains specialized integration tests for specific features:

```go
// Example structure:
TestVirtualNetworkWithPeering()      // Tests VNet peering functionality
TestVirtualNetworkPrivateEndpoint()  // Tests private endpoint support
TestVirtualNetworkDNS()              // Tests DNS configuration
TestVirtualNetworkFlowLogs()         // Tests flow logs functionality
TestVirtualNetworkValidationRules()  // Tests input validation (negative tests)
```

These tests:
- Are independent and can run standalone
- Focus on specific feature validation
- Include negative test scenarios
- Use the common `getTerraformOptions` helper

#### 3. Test Helpers (`test_helpers.go`)
Provides shared utilities for all tests:

```go
// Common test configuration
type TestConfig struct {
    SubscriptionID string
    TenantID      string
    ClientID      string
    ClientSecret  string
    Location      string
    ResourceGroup string
    UniqueID      string
}

// Helper functions
GetTestConfig()         // Retrieves Azure credentials
GetAzureCredential()    // Creates Azure SDK credential
getTerraformOptions()   // Creates Terraform options with random suffix
generateRandomSuffix()  // Generates unique identifiers
ValidateVirtualNetworkName() // Validates naming conventions
GetVirtualNetwork()     // Retrieves VNet using Azure SDK
```

#### 4. Performance Tests (`performance_test.go`)
Specialized tests for performance validation:

```go
TestVirtualNetworkScaling()      // Tests concurrent deployments
TestVirtualNetworkCreationTime() // Measures deployment duration
TestVirtualNetworkLargeAddressSpace() // Tests with multiple address spaces
```

### Test Fixtures Organization

Test fixtures are organized by scenario in the `fixtures/` directory:

```
tests/
├── fixtures/
│   ├── basic/              # Minimal viable configuration
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── complete/           # Full feature configuration
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── secure/             # Security-focused configuration
│   │   ├── main.tf
│   │   ├── network_watcher.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── network/            # Network peering scenario
│   ├── private_endpoint/   # Private endpoint configuration
│   └── negative/           # Invalid configurations for testing
│       ├── empty_address_space/
│       ├── invalid_name_chars/
│       ├── invalid_name_long/
│       └── invalid_name_short/
```

### Test Execution Flow

1. **Test Discovery**: Go test runner finds all `Test*` functions
2. **Parallel Execution**: Tests run concurrently when `t.Parallel()` is used
3. **Fixture Copy**: Tests copy fixtures to temp directories to avoid conflicts
4. **Terraform Execution**: 
   - `terraform init` - Initialize providers
   - `terraform apply` - Create resources
   - Output validation - Verify resource properties
   - `terraform destroy` - Clean up resources

### Running Tests

Using Go directly:
```bash
# Run all tests
go test -v ./...

# Run specific test function
go test -v -run TestVirtualNetworkBasic

# Run with timeout
go test -v -timeout 30m

# Run tests matching pattern
go test -v -run "TestVirtualNetwork.*"
```

Using Makefile:
```bash
# Run all tests
make test

# Run basic tests only
make test-basic

# Run specific test
make test-single TEST_NAME=TestVirtualNetworkBasic

# Run with coverage
make test-coverage
```

### Environment Variables

Tests require Azure credentials to be set:

```bash
# Required for Terraform provider
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"

# Optional - defaults to West Europe
export ARM_LOCATION="northeurope"

# For GitHub Actions (using OIDC)
export ARM_USE_OIDC=true
export ARM_USE_CLI=false
```

### Test Phases with test-structure

Each test follows a structured approach using Terratest's `test-structure` package:

```go
func TestVirtualNetworkBasic(t *testing.T) {
    t.Parallel()

    // 1. Setup Phase - Copy fixtures to temp directory
    fixtureFolder := "./fixtures/basic"
    tempFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", fixtureFolder)

    // 2. Configure Terraform options
    terraformOptions := &terraform.Options{
        TerraformDir: tempFolder,
        Vars: map[string]interface{}{
            "random_suffix": random.UniqueId(),
        },
        NoColor: true,
    }

    // 3. Save options for later stages
    test_structure.SaveTerraformOptions(t, tempFolder, terraformOptions)

    // 4. Cleanup Phase (deferred)
    defer test_structure.RunTestStage(t, "cleanup", func() {
        terraformOptions := test_structure.LoadTerraformOptions(t, tempFolder)
        terraform.Destroy(t, terraformOptions)
    })

    // 5. Deploy Phase
    test_structure.RunTestStage(t, "deploy", func() {
        terraform.InitAndApply(t, terraformOptions)
    })

    // 6. Validate Phase
    test_structure.RunTestStage(t, "validate", func() {
        terraformOptions := test_structure.LoadTerraformOptions(t, tempFolder)
        validateBasicVirtualNetwork(t, terraformOptions)
    })
}
```

### Validation Functions

Validation functions verify that resources were created correctly:

```go
func validateBasicVirtualNetwork(t *testing.T, terraformOptions *terraform.Options) {
    // Get outputs
    vnetID := terraform.Output(t, terraformOptions, "virtual_network_id")
    vnetName := terraform.Output(t, terraformOptions, "virtual_network_name")
    addressSpace := terraform.OutputList(t, terraformOptions, "virtual_network_address_space")
    
    // Assertions
    assert.NotEmpty(t, vnetID)
    assert.Contains(t, vnetName, "vnet-")
    assert.Len(t, addressSpace, 1)
    assert.Equal(t, "10.0.0.0/16", addressSpace[0])
    
    // Additional SDK validation if needed
    vnet := GetVirtualNetwork(t, vnetName, resourceGroupName, subscriptionID)
    assert.Equal(t, "Succeeded", *vnet.Properties.ProvisioningState)
}
```

### Basic Test Structure

```go
// modules/azurerm_storage_account/tests/integration/storage_account_test.go

package test

import (
    "crypto/tls"
    "fmt"
    "strings"
    "testing"
    "time"

    "github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/storage/armstorage"
    "github.com/gruntwork-io/terratest/modules/azure"
    "github.com/gruntwork-io/terratest/modules/random"
    "github.com/gruntwork-io/terratest/modules/terraform"
    test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestStorageAccountBasic(t *testing.T) {
    t.Parallel()

    // Generate unique names
    uniqueID := random.UniqueId()
    resourceGroupName := fmt.Sprintf("rg-test-%s", uniqueID)
    storageAccountName := fmt.Sprintf("satst%s", strings.ToLower(uniqueID))

    // Configure Terraform options
    terraformOptions := &terraform.Options{
        TerraformDir: "../../examples/basic",
        Vars: map[string]interface{}{
            "resource_group_name":  resourceGroupName,
            "location":            "northeurope",
            "storage_account_name": storageAccountName,
        },
        NoColor: true,
    }

    // Ensure cleanup
    defer terraform.Destroy(t, terraformOptions)

    // Deploy infrastructure
    terraform.InitAndApply(t, terraformOptions)

    // Validate outputs
    actualStorageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
    assert.Equal(t, storageAccountName, actualStorageAccountName)

    // Validate Azure resources
    subscriptionID := azure.GetSubscriptionID()
    account := azure.GetStorageAccount(t, subscriptionID, resourceGroupName, storageAccountName)
    
    assert.Equal(t, "Standard", string(account.Sku.Tier))
    assert.True(t, *account.Properties.EnableHTTPSTrafficOnly)
}
```

### Testing Matrix Pattern

```go
func TestStorageAccountMatrix(t *testing.T) {
    t.Parallel()

    testCases := []struct {
        name         string
        examplePath  string
        vars         map[string]interface{}
        validate     func(*testing.T, *terraform.Options)
    }{
        {
            name:        "Basic",
            examplePath: "../../examples/basic",
            vars: map[string]interface{}{
                "account_tier":             "Standard",
                "account_replication_type": "LRS",
            },
            validate: validateBasicConfiguration,
        },
        {
            name:        "Complete",
            examplePath: "../../examples/complete",
            vars: map[string]interface{}{
                "account_tier":             "Premium",
                "account_replication_type": "ZRS",
                "enable_private_endpoint":  true,
            },
            validate: validateCompleteConfiguration,
        },
        {
            name:        "WithNetworkRules",
            examplePath: "../../examples/network-restricted",
            vars: map[string]interface{}{
                "allowed_ip_ranges": []string{"1.2.3.4/32"},
            },
            validate: validateNetworkRules,
        },
    }

    for _, tc := range testCases {
        tc := tc // Capture range variable
        t.Run(tc.name, func(t *testing.T) {
            t.Parallel()
            
            terraformOptions := configureTerraformOptions(t, tc.examplePath, tc.vars)
            defer terraform.Destroy(t, terraformOptions)
            
            terraform.InitAndApply(t, terraformOptions)
            tc.validate(t, terraformOptions)
        })
    }
}
```

### Testing Network Connectivity

```go
func validateNetworkConnectivity(t *testing.T, terraformOptions *terraform.Options) {
    // Get the storage account endpoint
    endpoint := terraform.Output(t, terraformOptions, "primary_blob_endpoint")
    
    // Test HTTPS connectivity
    tlsConfig := &tls.Config{
        InsecureSkipVerify: false,
    }
    
    _, err := tls.Dial("tcp", endpoint+":443", tlsConfig)
    assert.NoError(t, err, "Should be able to establish TLS connection")
    
    // Test that HTTP is blocked (if HTTPS-only is enabled)
    httpEndpoint := strings.Replace(endpoint, "https://", "http://", 1)
    resp := http.Get(t, httpEndpoint, nil)
    assert.Equal(t, 403, resp.StatusCode, "HTTP should be forbidden")
}
```

### Testing IAM Permissions

```go
func validateIAMPermissions(t *testing.T, terraformOptions *terraform.Options) {
    // Get managed identity details
    identityID := terraform.Output(t, terraformOptions, "managed_identity_id")
    storageAccountID := terraform.Output(t, terraformOptions, "storage_account_id")
    
    // Use Azure SDK to verify role assignment
    roleAssignments := azure.ListRoleAssignments(t, subscriptionID)
    
    found := false
    for _, assignment := range roleAssignments {
        if assignment.Properties.PrincipalID == identityID &&
           strings.Contains(assignment.Properties.Scope, storageAccountID) {
            found = true
            assert.Contains(t, assignment.Properties.RoleDefinitionID, "Storage Blob Data Reader")
        }
    }
    
    assert.True(t, found, "Role assignment should exist")
}
```

## End-to-End Testing

E2E tests validate complete scenarios across multiple modules.

### Example: Multi-Module Test

```go
// tests/e2e/complete_infrastructure_test.go

func TestCompleteInfrastructure(t *testing.T) {
    t.Parallel()

    // Stage 1: Deploy networking
    networkingOptions := &terraform.Options{
        TerraformDir: "../../compositions/networking",
    }
    defer terraform.Destroy(t, networkingOptions)
    terraform.InitAndApply(t, networkingOptions)
    
    vnetID := terraform.Output(t, networkingOptions, "vnet_id")
    subnetID := terraform.Output(t, networkingOptions, "subnet_id")

    // Stage 2: Deploy storage with private endpoint
    storageOptions := &terraform.Options{
        TerraformDir: "../../modules/azurerm_storage_account/examples/private-endpoint",
        Vars: map[string]interface{}{
            "subnet_id": subnetID,
        },
    }
    defer terraform.Destroy(t, storageOptions)
    terraform.InitAndApply(t, storageOptions)

    // Stage 3: Deploy VM in the same network
    vmOptions := &terraform.Options{
        TerraformDir: "../../modules/azurerm_virtual_machine/examples/basic",
        Vars: map[string]interface{}{
            "subnet_id": subnetID,
        },
    }
    defer terraform.Destroy(t, vmOptions)
    terraform.InitAndApply(t, vmOptions)

    // Validate connectivity from VM to storage via private endpoint
    vmPublicIP := terraform.Output(t, vmOptions, "public_ip")
    storagePrivateIP := terraform.Output(t, storageOptions, "private_endpoint_ip")
    
    // SSH to VM and test private connectivity
    testCommand := fmt.Sprintf("nc -zv %s 443", storagePrivateIP)
    result := azure.RunSSHCommand(t, vmPublicIP, testCommand)
    assert.Contains(t, result, "succeeded")
}
```

## Security and Compliance Testing

### Static Security Analysis

Configure these tools in your CI pipeline:

```yaml
# .github/workflows/security-scan.yml

- name: Terraform Security Scan - tfsec
  uses: aquasecurity/tfsec-action@v1.0.0
  with:
    soft_fail: false

- name: Checkov Security Scan
  uses: bridgecrewio/checkov-action@master
  with:
    directory: modules/
    framework: terraform
    output_format: sarif
    output_file_path: checkov.sarif

- name: Upload SARIF
  uses: github/codeql-action/upload-sarif@v2
  with:
    sarif_file: checkov.sarif
```

### Azure Policy Compliance Testing

```go
func validateAzurePolicyCompliance(t *testing.T, resourceGroupName string) {
    // Wait for policy evaluation
    time.Sleep(2 * time.Minute)
    
    // Check compliance state
    complianceState := azure.GetPolicyComplianceState(t, subscriptionID, resourceGroupName)
    
    for _, result := range complianceState.Value {
        if result.ComplianceState == "NonCompliant" {
            t.Errorf("Resource %s is non-compliant with policy %s: %s", 
                result.ResourceID, 
                result.PolicyDefinitionName,
                result.PolicyDefinitionAction)
        }
    }
}
```

## Performance Testing

### Deployment Performance

Track and alert on deployment time regressions:

```go
func TestDeploymentPerformance(t *testing.T) {
    start := time.Now()
    
    terraform.InitAndApply(t, terraformOptions)
    
    duration := time.Since(start)
    t.Logf("Deployment took: %v", duration)
    
    // Alert if deployment takes too long
    maxDuration := 10 * time.Minute
    assert.Less(t, duration, maxDuration, 
        "Deployment exceeded maximum allowed time")
    
    // Track metrics (integrate with your monitoring)
    metrics.RecordDeploymentTime("storage_account", duration)
}
```

### Resource Performance Configuration

```go
func validatePerformanceSettings(t *testing.T, terraformOptions *terraform.Options) {
    // Verify performance-related settings
    tier := terraform.Output(t, terraformOptions, "account_tier")
    replication := terraform.Output(t, terraformOptions, "replication_type")
    
    if tier == "Premium" {
        assert.Equal(t, "ZRS", replication, 
            "Premium storage should use ZRS for performance")
    }
}
```

## Mock Strategies

### Using Native Test Mocks

For expensive or slow resources, use mocking in unit tests:

```hcl
# Test with mocked expensive database
mock_provider "azurerm" {
  mock_resource "azurerm_cosmosdb_account" {
    defaults = {
      id                = "/subscriptions/mock/resourceGroups/mock/providers/Microsoft.DocumentDB/databaseAccounts/mockdb"
      endpoint          = "https://mockdb.documents.azure.com:443/"
      connection_strings = ["AccountEndpoint=https://mockdb.documents.azure.com:443/;AccountKey=mockkey;"]
    }
  }
}

run "test_cosmos_outputs" {
  command = plan
  
  variables {
    enable_database = true
  }
  
  assert {
    condition     = length(output.database_connection_strings) > 0
    error_message = "Database connection strings should be populated"
  }
}
```

### Cost-Optimized Integration Testing

For Terratest, use the cheapest possible SKUs:

```go
// test_helpers.go

func GetTestSKUs() map[string]interface{} {
    return map[string]interface{}{
        // Virtual Machines
        "vm_size": "Standard_B1s",  // Cheapest VM
        
        // Storage
        "storage_account_tier": "Standard",
        "storage_replication":  "LRS",
        
        // Database
        "db_sku": "Basic",
        "db_capacity": 5,  // Minimum DTUs
        
        // App Service
        "app_service_sku": "F1",  // Free tier
    }
}
```

## CI/CD Integration

### Workflow Structure

```yaml
# .github/workflows/module-test.yml

name: Module Tests

on:
  pull_request:
    paths:
      - 'modules/**'
      - '.github/workflows/**'

jobs:
  detect-changes:
    runs-on: ubuntu-latest
    outputs:
      modules: ${{ steps.filter.outputs.changes }}
    steps:
      - uses: actions/checkout@v4
      - uses: dorny/paths-filter@v2
        id: filter
        with:
          filters: |
            storage_account: modules/azurerm_storage_account/**
            virtual_network: modules/azurerm_virtual_network/**
            key_vault: modules/azurerm_key_vault/**

  unit-test:
    needs: detect-changes
    if: ${{ needs.detect-changes.outputs.modules != '[]' }}
    runs-on: ubuntu-latest
    strategy:
      matrix:
        module: ${{ fromJson(needs.detect-changes.outputs.modules) }}
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.9.0
      
      - name: Run unit tests
        run: |
          cd modules/azurerm_${{ matrix.module }}
          terraform init
          terraform test

  integration-test:
    needs: [detect-changes, unit-test]
    if: ${{ needs.detect-changes.outputs.modules != '[]' }}
    runs-on: ubuntu-latest
    strategy:
      matrix:
        module: ${{ fromJson(needs.detect-changes.outputs.modules) }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: 1.21
      
      - name: Azure Login
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      
      - name: Run integration tests
        run: |
          cd modules/azurerm_${{ matrix.module }}
          go test -v -timeout 30m ./tests/integration
        env:
          ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          ARM_USE_OIDC: true
```

### Test Result Reporting

```yaml
- name: Publish Test Results
  uses: EnricoMi/publish-unit-test-result-action@v2
  if: always()
  with:
    files: |
      **/*_test.xml
    check_name: Terratest Results
    comment_mode: failures
```

## Test Organization

### Recommended Directory Structure

```
azurerm-terraform-modules/
├── .github/
│   ├── workflows/
│   │   ├── pr-validation.yml       # Linting and static analysis
│   │   ├── module-unit-tests.yml   # Native Terraform tests
│   │   ├── module-integration.yml  # Terratest execution
│   │   └── nightly-e2e.yml        # Full E2E test suite
│   └── test-config/
│       └── test-matrix.json        # Test configuration matrix
├── modules/
│   └── azurerm_storage_account/
│       ├── examples/
│       │   ├── basic/              # Minimal configuration
│       │   ├── complete/           # All features enabled
│       │   ├── secure/             # Security-focused example
│       │   └── private-endpoint/   # Network isolation example
│       ├── tests/
│       │   ├── unit/               # Native Terraform tests
│       │   │   ├── defaults.tftest.hcl
│       │   │   ├── naming.tftest.hcl
│       │   │   ├── outputs.tftest.hcl
│       │   │   └── validation.tftest.hcl
│       │   └── integration/        # Terratest Go tests
│       │       ├── storage_account_test.go
│       │       ├── network_test.go
│       │       ├── security_test.go
│       │       └── test_helpers.go
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
└── tests/
    └── e2e/                        # Cross-module E2E tests
        ├── complete_stack_test.go
        └── scenarios/
```

## Best Practices

### 1. Test Naming Conventions

- **Unit Tests**: `test_<feature>_<scenario>.tftest.hcl`
- **Integration Tests**: `Test<Module><Feature>(t *testing.T)`
- **E2E Tests**: `TestE2E<Scenario>(t *testing.T)`

### 2. Test Data Management

```go
// Use unique IDs to prevent conflicts
uniqueID := strings.ToLower(random.UniqueId())

// Prefix resources for easy identification
resourcePrefix := fmt.Sprintf("tftest-%s", uniqueID)

// Tag all test resources
tags := map[string]string{
    "Purpose":    "TerraformTest",
    "TestID":     uniqueID,
    "Repository": "azurerm-terraform-modules",
    "Ephemeral":  "true",
}
```

### 3. Parallel Test Execution

```go
func TestModuleParallel(t *testing.T) {
    t.Parallel() // Enable parallel execution
    
    // Ensure unique resource names
    uniqueID := random.UniqueId()
    // ... rest of test
}
```

### 4. Cleanup Strategies

```go
// Always destroy resources, even on test failure
defer func() {
    terraform.Destroy(t, terraformOptions)
    
    // Additional cleanup if needed
    azure.DeleteResourceGroup(t, resourceGroupName)
}()

// For E2E tests, destroy in reverse order
defer terraform.Destroy(t, appOptions)
defer terraform.Destroy(t, dbOptions)
defer terraform.Destroy(t, networkOptions)
```

### 5. Assertion Strategies

```go
// Use require for critical assertions that should stop the test
require.NoError(t, err, "Deployment should succeed")

// Use assert for non-critical validations
assert.Equal(t, expected, actual, "Value should match")

// Custom validation functions for complex checks
validateNetworkSecurity(t, terraformOptions)
validateTagCompliance(t, resourceGroupName)
```

## Common Patterns

### Pattern: Retry for Eventually Consistent Resources

```go
func waitForDNSPropagation(t *testing.T, hostname string) {
    maxRetries := 30
    sleepBetweenRetries := 10 * time.Second
    
    for i := 0; i < maxRetries; i++ {
        _, err := net.LookupHost(hostname)
        if err == nil {
            return
        }
        time.Sleep(sleepBetweenRetries)
    }
    
    t.Fatalf("DNS failed to propagate for %s", hostname)
}
```

### Pattern: Testing Module Composition

```hcl
# tests/unit/composition.tftest.hcl

run "modules_work_together" {
  command = plan
  
  module {
    source = "./tests/fixtures/multi-module"
  }
  
  assert {
    condition     = module.storage.storage_account_id != ""
    error_message = "Storage module should produce account ID"
  }
  
  assert {
    condition     = contains(module.vm.security_rules, module.storage.private_endpoint_ip)
    error_message = "VM should have security rule for storage private endpoint"
  }
}
```

### Pattern: Environment-Specific Testing

```go
func skipInCI(t *testing.T) {
    if os.Getenv("CI") == "true" {
        t.Skip("Skipping test in CI environment")
    }
}

func requiresHigherLimits(t *testing.T) {
    if os.Getenv("TEST_SUBSCRIPTION_TYPE") != "enterprise" {
        t.Skip("Test requires enterprise subscription limits")
    }
}
```

## Troubleshooting

### Common Issues and Solutions

1. **"Subscription Quota Exceeded"**
   - Use smaller SKUs in tests
   - Implement test queuing in CI
   - Clean up orphaned resources regularly

2. **"Resource Already Exists"**
   - Always use unique names with `random.UniqueId()`
   - Implement proper cleanup in defer blocks
   - Check for leaked resources from failed tests

3. **"Test Timeout"**
   - Increase timeout for integration tests: `-timeout 45m`
   - Use parallel execution where possible
   - Consider splitting large tests

4. **"Provider Authentication Failed"**
   - Ensure OIDC is properly configured
   - Check service principal permissions
   - Verify environment variables are set

## Summary

This testing guide provides a comprehensive framework for testing Terraform modules at multiple levels:

1. **Unit tests** with native Terraform tests for fast, logic-focused validation
2. **Integration tests** with Terratest for real infrastructure validation
3. **E2E tests** for complete scenario validation
4. **Security and compliance** testing embedded throughout
5. **Cost-optimized** strategies using mocks and minimal SKUs
6. **CI/CD integration** with parallel execution and smart path filtering

By following these patterns and practices, you can ensure your Terraform modules are reliable, secure, and production-ready while maintaining fast feedback loops and controlling costs.