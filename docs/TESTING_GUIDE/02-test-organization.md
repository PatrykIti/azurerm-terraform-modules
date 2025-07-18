# Test Organization & Structure

## Directory Structure Standards

All modules must follow a consistent directory structure for tests to ensure maintainability and discoverability.

### Complete Module Structure

```
modules/azurerm_storage_account/
├── main.tf                           # Module implementation
├── variables.tf                      # Input variables
├── outputs.tf                        # Output values
├── versions.tf                       # Provider requirements
├── README.md                         # Module documentation
├── examples/                         # Usage examples
│   ├── basic/                       # Minimal configuration
│   ├── complete/                    # Full feature set
│   ├── secure/                      # Security-hardened
│   └── private-endpoint/            # Network isolation
└── tests/                           # All test files
    ├── unit/                        # Native Terraform tests
    │   ├── defaults.tftest.hcl     # Default value testing
    │   ├── naming.tftest.hcl        # Naming convention tests
    │   ├── outputs.tftest.hcl       # Output validation
    │   ├── validation.tftest.hcl    # Input validation
    │   └── containers.tftest.hcl    # Conditional logic tests
    ├── fixtures/                    # Terratest test scenarios
    │   ├── basic/                   # Maps to examples/basic
    │   ├── complete/                # Maps to examples/complete
    │   ├── secure/                  # Maps to examples/secure
    │   ├── private_endpoint/        # Maps to examples/private-endpoint
    │   └── negative/                # Invalid configurations
    │       ├── invalid_name_chars/
    │       ├── invalid_name_short/
    │       └── invalid_replication/
    ├── go.mod                       # Go module definition
    ├── go.sum                       # Go dependency checksums
    ├── Makefile                     # Test execution targets
    ├── test_helpers.go              # Shared test utilities
    ├── storage_account_test.go      # Main integration tests
    ├── integration_test.go          # Advanced integration tests
    ├── performance_test.go          # Performance benchmarks
    ├── test_config.yaml            # Test configuration
    ├── test_env.sh                  # Environment setup script
    ├── run_tests_parallel.sh       # Parallel test execution
    ├── run_tests_sequential.sh     # Sequential test execution
    └── test_outputs/                # Test result artifacts
        └── .gitkeep
```

## Test File Naming Conventions

### Native Terraform Tests (Unit Tests)

Located in `tests/unit/`, these files test module logic without deploying infrastructure:

| File | Purpose | Test Count | Description |
|------|---------|------------|-------------|
| `defaults.tftest.hcl` | Default Values | 4-8 tests | Verify secure defaults are applied |
| `naming.tftest.hcl` | Naming Logic | 6-12 tests | Test naming conventions and constraints |
| `outputs.tftest.hcl` | Output Values | 3-6 tests | Validate output structure and formatting |
| `validation.tftest.hcl` | Input Validation | 10-20 tests | Test variable validation rules |
| `containers.tftest.hcl` | Conditional Logic | 5-10 tests | Test conditional resource creation |

**Naming Pattern**: `{feature}.tftest.hcl`

### Terratest Files (Integration Tests)

Located in `tests/`, these files test real Azure infrastructure:

| File | Purpose | Description |
|------|---------|-------------|
| `{module}_test.go` | Main Tests | Primary test orchestration and basic scenarios |
| `integration_test.go` | Advanced Tests | Complex integration scenarios and lifecycle tests |
| `performance_test.go` | Performance | Benchmarks and performance validation |
| `test_helpers.go` | Utilities | Shared helper functions and Azure SDK integration |

**Naming Pattern**: `{module_name}_test.go` for main tests, descriptive names for specialized tests.

### Test Fixtures

Located in `tests/fixtures/`, these directories contain Terraform configurations for testing:

| Directory | Purpose | Maps To |
|-----------|---------|---------|
| `basic/` | Minimal Configuration | `examples/basic/` |
| `complete/` | Full Features | `examples/complete/` |
| `secure/` | Security Hardened | `examples/secure/` |
| `private_endpoint/` | Network Isolation | `examples/private-endpoint/` |
| `negative/` | Invalid Configs | N/A (validation testing) |

## Test Function Naming Conventions

### Native Terraform Tests

```hcl
# Pattern: {action}_{feature}_{scenario}
run "verify_secure_defaults" { }
run "test_naming_constraints" { }
run "validate_output_structure" { }
run "check_container_creation" { }

# Negative tests
run "invalid_storage_account_name_too_short" {
  expect_failures = [var.storage_account_name]
}
```

### Terratest Functions

```go
// Pattern: Test{Module}{Feature}
func TestStorageAccountBasic(t *testing.T) { }
func TestStorageAccountComplete(t *testing.T) { }
func TestStorageAccountSecurity(t *testing.T) { }
func TestStorageAccountNetworkRules(t *testing.T) { }

// Integration tests
func TestStorageAccountLifecycle(t *testing.T) { }
func TestStorageAccountDisasterRecovery(t *testing.T) { }

// Performance tests
func BenchmarkStorageAccountCreation(b *testing.B) { }
func TestStorageAccountCreationTime(t *testing.T) { }
```

## Test Categorization

### By Test Type

#### Unit Tests (Native Terraform)
- **Purpose**: Logic validation without infrastructure
- **Location**: `tests/unit/*.tftest.hcl`
- **Execution**: `terraform test`
- **Duration**: < 30 seconds per file
- **Cost**: Free

#### Integration Tests (Terratest)
- **Purpose**: Real infrastructure validation
- **Location**: `tests/*_test.go`
- **Execution**: `go test`
- **Duration**: 5-30 minutes per test
- **Cost**: Minimal Azure charges

#### Performance Tests (Terratest)
- **Purpose**: Benchmarking and performance validation
- **Location**: `tests/performance_test.go`
- **Execution**: `go test -bench=.`
- **Duration**: 10-60 minutes
- **Cost**: Moderate Azure charges

### By Test Scope

#### Basic Tests
- **Trigger**: Every commit
- **Duration**: < 5 minutes
- **Includes**: Unit tests + basic integration
- **Purpose**: Fast feedback loop

#### Complete Tests
- **Trigger**: Pull requests
- **Duration**: < 30 minutes
- **Includes**: All tests except performance
- **Purpose**: Comprehensive validation

#### Full Tests
- **Trigger**: Main branch, releases
- **Duration**: < 60 minutes
- **Includes**: All tests including performance
- **Purpose**: Production readiness

### By Test Focus

#### Functional Tests
```go
// Test basic functionality
TestStorageAccountBasic()
TestStorageAccountComplete()

// Test specific features
TestStorageAccountContainers()
TestStorageAccountEncryption()
```

#### Security Tests
```go
// Test security configurations
TestStorageAccountSecurity()
TestStorageAccountNetworkRules()
TestStorageAccountPrivateEndpoint()

// Test compliance
TestStorageAccountCompliance()
```

#### Negative Tests
```go
// Test validation rules
TestStorageAccountValidationRules()

// Test error scenarios
TestStorageAccountInvalidConfiguration()
```

## Test Execution Patterns

### Sequential vs Parallel Execution

#### Parallel Execution (Default)
```go
func TestStorageAccountBasic(t *testing.T) {
    t.Parallel() // Enable parallel execution
    
    // Use unique resource names
    uniqueID := random.UniqueId()
    resourceName := fmt.Sprintf("test-%s", uniqueID)
    
    // Test implementation
}
```

**Benefits**:
- Faster total execution time
- Better resource utilization
- Suitable for independent tests

**Requirements**:
- Unique resource naming
- No shared state between tests
- Proper cleanup handling

#### Sequential Execution (When Needed)
```go
func TestStorageAccountLifecycle(t *testing.T) {
    // No t.Parallel() - runs sequentially
    
    // Tests that modify shared resources
    // or have dependencies between steps
}
```

**Use Cases**:
- Tests with shared resources
- Lifecycle testing (create → modify → delete)
- Resource quota limitations
- Debugging scenarios

### Test Phases with test-structure

All integration tests follow a structured approach:

```go
func TestStorageAccountBasic(t *testing.T) {
    t.Parallel()

    // 1. Setup Phase
    fixtureFolder := "./fixtures/basic"
    tempFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", fixtureFolder)

    // 2. Configuration Phase
    terraformOptions := getTerraformOptions(t, tempFolder)
    test_structure.SaveTerraformOptions(t, tempFolder, terraformOptions)

    // 3. Cleanup Phase (deferred)
    defer test_structure.RunTestStage(t, "cleanup", func() {
        terraformOptions := test_structure.LoadTerraformOptions(t, tempFolder)
        terraform.Destroy(t, terraformOptions)
    })

    // 4. Deploy Phase
    test_structure.RunTestStage(t, "deploy", func() {
        terraform.InitAndApply(t, terraformOptions)
    })

    // 5. Validate Phase
    test_structure.RunTestStage(t, "validate", func() {
        terraformOptions := test_structure.LoadTerraformOptions(t, tempFolder)
        validateBasicStorageAccount(t, terraformOptions)
    })
}
```

## Test Data Management

### Unique Resource Naming

All tests must use unique resource names to prevent conflicts:

```go
// Generate unique suffix
func generateRandomSuffix() string {
    return strings.ToLower(random.UniqueId())
}

// Apply to resource names
func getTerraformOptions(t *testing.T, terraformDir string) *terraform.Options {
    randomSuffix := generateRandomSuffix()
    
    return &terraform.Options{
        TerraformDir: terraformDir,
        Vars: map[string]interface{}{
            "random_suffix": randomSuffix,
            "location":      "northeurope",
        },
        NoColor: true,
    }
}
```

### Test Tagging Strategy

All test resources must be tagged for identification and cleanup:

```go
// Standard test tags
func getTestTags(testID string) map[string]string {
    return map[string]string{
        "Purpose":     "TerraformTest",
        "TestID":      testID,
        "Repository":  "azurerm-terraform-modules",
        "Ephemeral":   "true",
        "CreatedBy":   "Terratest",
        "Environment": "Test",
    }
}
```

### Environment Variables

Tests require specific environment variables:

```bash
# Required for Azure authentication
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"

# Optional configuration
export ARM_LOCATION="northeurope"
export TEST_TIMEOUT="30m"
export TEST_PARALLEL="8"
```

## Test Configuration Files

### go.mod Structure

```go
module github.com/PatrykIti/azurerm-terraform-modules/modules/azurerm_storage_account/tests

go 1.21

require (
    github.com/Azure/azure-sdk-for-go/sdk/azcore v1.9.0
    github.com/Azure/azure-sdk-for-go/sdk/azidentity v1.4.0
    github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/storage/armstorage v1.5.0
    github.com/gruntwork-io/terratest v0.46.7
    github.com/stretchr/testify v1.8.4
)
```

### test_config.yaml Structure

```yaml
# Test configuration for CI/CD integration
test_suites:
  - name: "Basic Tests"
    tests: [TestBasicStorageAccount]
    parallel: true
    timeout: 15m
    
  - name: "Complete Feature Tests"
    tests: [TestCompleteStorageAccount, TestStorageAccountSecurity]
    parallel: true
    timeout: 30m
    
  - name: "Performance Tests"
    tests: [BenchmarkStorageAccountCreation]
    parallel: false
    timeout: 60m
    benchmark: true

# Environment requirements
environment:
  required_vars: [AZURE_SUBSCRIPTION_ID, AZURE_TENANT_ID, AZURE_CLIENT_ID, AZURE_CLIENT_SECRET]
  azure_regions: [northeurope, westeurope]
  resource_limits:
    max_storage_accounts: 10
    max_resource_groups: 5

# Coverage settings
coverage:
  enabled: true
  threshold: 80
  exclude_patterns: ["test_helpers.go", "*_test.go"]
```

### Makefile Structure

```makefile
# Makefile for Terratest execution

# Variables
TIMEOUT ?= 30m
TEST_FILTER ?= Test
PARALLEL ?= 8
AZURE_LOCATION ?= northeurope

# Environment check
check-env:
	@echo "Checking required environment variables..."
	@test -n "$(AZURE_SUBSCRIPTION_ID)" || (echo "AZURE_SUBSCRIPTION_ID is not set" && exit 1)
	@test -n "$(AZURE_TENANT_ID)" || (echo "AZURE_TENANT_ID is not set" && exit 1)
	@test -n "$(AZURE_CLIENT_ID)" || (echo "AZURE_CLIENT_ID is not set" && exit 1)
	@test -n "$(AZURE_CLIENT_SECRET)" || (echo "AZURE_CLIENT_SECRET is not set" && exit 1)
	@echo "All required environment variables are set."

# Install dependencies
deps:
	@echo "Installing Go dependencies..."
	go mod download
	go mod tidy

# Run all tests
test: check-env deps
	@echo "Running all tests..."
	go test -v -timeout $(TIMEOUT) -parallel $(PARALLEL) ./...

# Run basic tests only
test-basic: check-env deps
	@echo "Running basic tests..."
	go test -v -timeout 15m -run TestBasicStorageAccount ./...

# Run security tests
test-security: check-env deps
	@echo "Running security tests..."
	go test -v -timeout 20m -run TestStorageAccountSecurity ./...

# Run with coverage
test-coverage: check-env deps
	@echo "Running tests with coverage..."
	go test -v -timeout $(TIMEOUT) -coverprofile=coverage.out -covermode=atomic ./...
	go tool cover -html=coverage.out -o coverage.html

# Clean test artifacts
clean:
	@echo "Cleaning test artifacts..."
	rm -f coverage.out coverage.html test-results.xml
	find . -name "*.tfstate*" -type f -delete
	find . -name ".terraform" -type d -exec rm -rf {} +

.PHONY: check-env deps test test-basic test-security test-coverage clean
```

## Test Execution Scripts

### Parallel Test Execution

```bash
#!/bin/bash
# run_tests_parallel.sh

# Source environment variables
source ./test_env.sh

# Create output directory for test results
OUTPUT_DIR="test_outputs/parallel_run_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Function to run a single test and save output
run_test() {
    local test_name=$1
    local output_file="$OUTPUT_DIR/${test_name}.json"
    local log_file="$OUTPUT_DIR/${test_name}.log"
    
    echo "[$(date +%H:%M:%S)] Starting test: $test_name"
    
    local start_time=$(date +%s)
    go test -v -timeout 30m -run "^${test_name}$" . 2>&1 > "$log_file"
    local exit_status=$?
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Create JSON output
    cat > "$output_file" << EOF
{
  "test_name": "$test_name",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "exit_status": $exit_status,
  "duration_seconds": $duration,
  "success": $([ $exit_status -eq 0 ] && echo "true" || echo "false"),
  "log_file": "$(basename "$log_file")"
}
EOF
    
    echo "[$(date +%H:%M:%S)] Completed test: $test_name (${duration}s)"
    return $exit_status
}

# List of tests to run
tests=(
    "TestBasicStorageAccount"
    "TestCompleteStorageAccount"
    "TestStorageAccountSecurity"
    "TestStorageAccountNetworkRules"
    "TestStorageAccountPrivateEndpoint"
    "TestStorageAccountValidationRules"
)

echo "Starting parallel test execution"
echo "Total tests to run: ${#tests[@]}"
echo "Output directory: $OUTPUT_DIR"

# Array to store PIDs of background jobs
declare -a pids=()

# Run all tests in parallel
for test in "${tests[@]}"; do
    run_test "$test" &
    pids+=($!)
done

# Wait for all background jobs to complete
echo "Waiting for all tests to complete..."
for pid in "${pids[@]}"; do
    wait "$pid" || true
done

echo "All tests completed. Results saved in: $OUTPUT_DIR"
```

### Sequential Test Execution

```bash
#!/bin/bash
# run_tests_sequential.sh

# Source environment variables
source ./test_env.sh

# Create output directory
OUTPUT_DIR="test_outputs/sequential_run_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Function to run a single test
run_test() {
    local test_name=$1
    local output_file="$OUTPUT_DIR/${test_name}.json"
    local log_file="$OUTPUT_DIR/${test_name}.log"
    
    echo "Running test: $test_name"
    
    go test -v -timeout 30m -run "^${test_name}$" . 2>&1 | tee "$log_file"
    local exit_status=${PIPESTATUS[0]}
    
    # Create JSON output
    cat > "$output_file" << EOF
{
  "test_name": "$test_name",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "exit_status": $exit_status,
  "success": $([ $exit_status -eq 0 ] && echo "true" || echo "false"),
  "log_file": "$log_file"
}
EOF
    
    echo "Test $test_name completed with status: $exit_status"
    return $exit_status
}

# List of tests to run
tests=(
    "TestBasicStorageAccount"
    "TestCompleteStorageAccount"
    "TestStorageAccountSecurity"
    "TestStorageAccountNetworkRules"
    "TestStorageAccountPrivateEndpoint"
    "TestStorageAccountValidationRules"
)

echo "Starting sequential test execution"
echo "Total tests to run: ${#tests[@]}"

# Run each test sequentially
for test in "${tests[@]}"; do
    run_test "$test" || true
done

echo "Sequential test execution completed!"
echo "Results saved in: $OUTPUT_DIR"
```

## Best Practices for Test Organization

### 1. Consistent Structure
- All modules follow the same directory structure
- Predictable file naming conventions
- Clear separation between unit and integration tests

### 2. Logical Grouping
- Group related tests in the same file
- Separate concerns (basic, security, network, performance)
- Use descriptive test names that explain the scenario

### 3. Fixture Management
- One fixture per test scenario
- Fixtures mirror examples structure
- Include negative test fixtures for validation

### 4. Resource Management
- Use unique naming to prevent conflicts
- Implement proper cleanup strategies
- Tag all test resources for identification

### 5. Documentation
- Document test purpose and scope
- Include setup instructions
- Provide troubleshooting guidance

## Next Steps

Now that you understand test organization, proceed to:

1. **[Native Terraform Tests](03-native-terraform-tests.md)** - Learn unit testing with HCL
2. **[Variable Validation Testing](04-variable-validation.md)** - Test input constraints
3. **[Terratest Framework](05-terratest-framework.md)** - Implement integration tests

---

**Key Takeaways**:
- Follow consistent directory structure across all modules
- Use descriptive naming conventions for tests and fixtures
- Implement proper resource management and cleanup
- Organize tests by type, scope, and focus area
- Use configuration files to standardize test execution
