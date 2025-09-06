# Storage Account Module Tests

This directory contains comprehensive Terratest suite for the Azure Storage Account Terraform module.

## Test Structure

```
tests/
├── storage_account_test.go    # Basic test cases (run on PRs)
├── integration_test.go       # Integration tests (run on main branch)
├── performance_test.go       # Performance tests (run on main branch)
├── test_helpers.go           # Helper functions and utilities
├── fixtures/                 # Terraform configurations for testing
│   ├── simple/              # Basic storage account test
│   ├── complete/            # Full feature test
│   ├── security/            # Security configuration test
│   ├── network/             # Network rules test
│   ├── private_endpoint/    # Private endpoint test
│   └── negative/            # Validation failure tests
├── test_config.yaml         # CI/CD test configuration
├── Makefile                 # Test execution helpers
├── go.mod                   # Go module definition
└── README.md               # This file
```

### Test Categories

1. **Short Tests (Run on PRs)** - Basic functionality tests that complete quickly
   - Marked without `testing.Short()` check
   - Timeout: 30 minutes
   - Includes: Basic, Security, Network, Validation tests

2. **Integration Tests (Run on main branch)** - Comprehensive integration tests
   - Include `if testing.Short() { t.Skip(...) }` check
   - Timeout: 60 minutes
   - Includes: Full Integration, Lifecycle, Disaster Recovery, Compliance

3. **Performance Tests (Run on main branch)** - Performance benchmarks
   - Include `if testing.Short() { t.Skip(...) }` check
   - Timeout: 60 minutes
   - Includes: Creation Time, Scaling tests

## Prerequisites

1. **Azure Credentials**: Set the following environment variables:
   ```bash
   export AZURE_SUBSCRIPTION_ID="your-subscription-id"
   export AZURE_TENANT_ID="your-tenant-id"
   export AZURE_CLIENT_ID="your-client-id"
   export AZURE_CLIENT_SECRET="your-client-secret"
   ```

2. **Go**: Install Go 1.21 or later
3. **Terraform**: Install Terraform 1.3.0 or later

## Running Tests

### Run All Tests
```bash
make test-all
```

### Run Test Categories
```bash
# Run only short tests (basic functionality) - 30min timeout
make test-short

# Run only integration tests - 60min timeout
make test-integration

# Run all tests - 60min timeout
make test-all
```

### Run Specific Test Suite
```bash
# Basic tests only
make test-basic

# Security tests
make test-security

# Network tests
make test-network

# Private endpoint tests
make test-private-endpoint

# Validation tests
make test-validation
```

### Run Single Test
```bash
make test-single TEST_NAME=TestBasicStorageAccount
```

### Run with Coverage
```bash
make test-coverage
```

### Run Benchmarks
```bash
make benchmark
```

### Direct Go Test Commands
```bash
cd tests
# Short tests only (excludes integration/performance tests)
go test -v -short -parallel 8 -timeout 30m

# All tests
go test -v -parallel 8 -timeout 60m

# Only integration tests
go test -v -run "Integration|Lifecycle|Disaster|Compliance|Monitoring|Scaling" -parallel 8 -timeout 60m
```

## Test Cases

### 1. Basic Storage Account Test (`TestBasicStorageAccount`)
- Creates a simple storage account with default settings
- Validates basic properties and secure defaults
- Verifies HTTPS-only and TLS 1.2 requirements

### 2. Complete Storage Account Test (`TestCompleteStorageAccount`)
- Tests all module features including:
  - Containers creation
  - Network rules
  - Blob properties (versioning, soft delete)
  - Diagnostic settings
  - Tags

### 3. Security Test (`TestStorageAccountSecurity`)
- Validates security configurations:
  - HTTPS traffic only
  - TLS version
  - Public blob access disabled
  - Infrastructure encryption
  - Advanced threat protection

### 4. Network Rules Test (`TestStorageAccountNetworkRules`)
- Tests network access controls:
  - IP rules
  - Subnet rules
  - Default deny action
  - Service endpoints
  - CORS rules

### 5. Private Endpoint Test (`TestStorageAccountPrivateEndpoint`)
- Validates private endpoint configuration
- Tests public network access disabled
- Verifies private DNS zone integration

### 6. Validation Rules Test (`TestStorageAccountValidationRules`)
Negative test cases for input validation:
- Invalid storage account name (too short)
- Invalid characters in name
- Invalid account tier
- Invalid replication type
- Invalid container access type

### 7. Performance Benchmark (`BenchmarkStorageAccountCreation`)
- Measures storage account creation time
- Helps identify performance regressions

## Helper Functions

The `test_helpers.go` file provides utilities for:
- Storage account property validation
- Encryption settings verification
- Network rules validation
- Container existence checks
- Test fixture generation
- Azure SDK client helpers

## CI/CD Integration

### Azure DevOps Pipeline
```yaml
trigger:
  - main
  - develop

pool:
  vmImage: 'ubuntu-latest'

variables:
  - group: terraform-azure-credentials

steps:
  - task: GoTool@0
    inputs:
      version: '1.21'
  
  - script: |
      cd azurerm_storage_account/tests
      make ci
    displayName: 'Run Tests'
    env:
      ARM_SUBSCRIPTION_ID: $(ARM_SUBSCRIPTION_ID)
      ARM_TENANT_ID: $(ARM_TENANT_ID)
      ARM_CLIENT_ID: $(ARM_CLIENT_ID)
      ARM_CLIENT_SECRET: $(ARM_CLIENT_SECRET)
```

### GitHub Actions

The module uses automated CI/CD workflow that runs:
- **On Pull Requests**: Only short tests (30min timeout)
- **On Push to main/release**: All tests including integration (60min timeout)
- **Manual Trigger**: Can be triggered manually with custom options

#### Manual Workflow Dispatch

You can manually trigger tests from GitHub Actions:

1. Go to **Actions** → **Module CI**
2. Click **"Run workflow"**
3. Select options:
   - **Test type**:
     - `short` - Only basic tests (default for PRs)
     - `full` - All tests including integration
     - `integration-only` - Only integration tests
   - **Module**: Specific module name (e.g., `azurerm_storage_account`) or leave empty for all

Example workflow configuration:
```yaml
name: Module CI

on:
  pull_request:
    paths:
      - 'modules/**'
  push:
    branches: [ main, release/** ]
  workflow_dispatch:
    inputs:
      test_type:
        description: 'Type of tests to run'
        required: true
        default: 'short'
        type: choice
        options:
          - short
          - full
          - integration-only
      module:
        description: 'Specific module to test'
        required: false
        type: string

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v5
    
    - name: Set up Go
      uses: actions/setup-go@v5
      with:
        go-version: '1.21'
    
    - name: Run tests
      env:
        ARM_SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTION_ID }}
        ARM_TENANT_ID: ${{ secrets.ARM_TENANT_ID }}
        ARM_CLIENT_ID: ${{ secrets.ARM_CLIENT_ID }}
        ARM_CLIENT_SECRET: ${{ secrets.ARM_CLIENT_SECRET }}
      run: |
        cd modules/azurerm_storage_account/tests
        # Test type is determined by workflow trigger
        # PRs run short tests, main branch runs all tests
        make test
```

## Test Configuration

The `test_config.yaml` file defines:
- Test suite groupings
- Timeout settings
- Parallel execution limits
- Coverage thresholds (80%)
- Retry policies
- Environment requirements

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Ensure all ARM_* environment variables are set
   - Verify service principal has required permissions

2. **Resource Already Exists**
   - Tests use random suffixes to avoid conflicts
   - Run `make clean` to remove any leftover resources

3. **Timeout Errors**
   - Increase timeout using `TIMEOUT` variable: `make test TIMEOUT=45m`
   - Some regions may be slower than others

4. **Network Connectivity**
   - Ensure your test environment can reach Azure endpoints
   - Check for proxy settings if behind corporate firewall

### Debug Mode

Run tests with verbose logging:
```bash
go test -v -timeout 30m -run TestBasicStorageAccount ./... -args -debug
```

## Best Practices

1. **Parallel Execution**: Tests run in parallel by default for speed
2. **Resource Cleanup**: All tests clean up resources in defer blocks
3. **Unique Naming**: Random suffixes prevent naming conflicts
4. **Idempotency**: Tests can be re-run without manual cleanup
5. **Fast Feedback**: Basic tests run first, complex tests later

## Contributing

When adding new tests:
1. Follow the existing test structure
2. Add appropriate fixtures in `fixtures/` directory
3. Update this README with test description
4. Ensure >80% code coverage is maintained
5. Add negative test cases for new validations
6. For integration/performance tests, add `testing.Short()` check:
   ```go
   if testing.Short() {
       t.Skip("Skipping integration test in short mode")
   }
   ```
7. Use `t.Parallel()` for all tests to enable parallel execution
8. Keep basic functionality tests under 5 minutes execution time