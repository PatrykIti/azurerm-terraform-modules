# Network Security Group Module Tests

This directory contains automated tests for the Azure Network Security Group (NSG) Terraform module, structured according to the project's standardized testing guidelines.

## Test Structure

The test organization follows the official [Testing Guide](../../../docs/TESTING_GUIDE/README.md).

```
tests/
├── fixtures/                # Terraform configurations for test scenarios
│   ├── simple/              # Minimal valid configuration
│   ├── complete/            # All features enabled (rules, flow logs, etc.)
│   ├── security/            # Security-hardened rule examples
│   └── negative/            # Intentionally invalid configurations
├── unit/                    # Native Terraform tests (.tftest.hcl)
│   ├── defaults.tftest.hcl
│   └── validation.tftest.hcl
├── go.mod                   # Go module dependencies
├── go.sum                   # Dependency checksums
├── Makefile                 # Standardized test execution commands
├── network_security_group_test.go  # Main tests for core scenarios
├── integration_test.go      # Advanced tests (lifecycle, compliance)
├── performance_test.go      # Performance benchmarks and SLA tests
└── test_helpers.go          # Helper functions for Azure SDK interaction
```

## Running Tests

### Prerequisites
- Go (version specified in `go.mod`)
- Terraform
- Azure CLI with an active login (`az login`)
- Required environment variables set (see below)

### Environment Variables
Before running integration tests, you must export the following environment variables:
```bash
export AZURE_SUBSCRIPTION_ID="your-subscription-id"
export AZURE_TENANT_ID="your-tenant-id"
export AZURE_CLIENT_ID="your-client-id"
export AZURE_CLIENT_SECRET="your-client-secret"
```

### Test Execution
All test commands should be run from within this `tests` directory. The `Makefile` provides standardized targets for all common operations.

**Run all tests:**
```bash
make test
```

**Run a single specific test:**
```bash
make test-single TEST_NAME=TestNsgSimple
```

**Run performance benchmarks:**
```bash
make benchmark
```

**Generate a coverage report:**
```bash
make test-coverage
```

**Clean up all test artifacts:**
```bash
make clean
```

For a full list of available commands, run `make help`.

## Writing New Tests

Please adhere to the patterns established in the [Testing Guide](../../../docs/TESTING_GUIDE/README.md) and the existing test files.

- **Unit Tests**: Add new `.tftest.hcl` files to the `tests/unit/` directory to test module logic without deploying resources.
- **Integration Tests**:
  - Add basic scenario tests to `network_security_group_test.go`.
  - Add advanced lifecycle or compliance tests to `integration_test.go`.
  - Add performance tests to `performance_test.go`.
- **Helpers**: Add new validation or utility functions to `test_helpers.go`.
- **Fixtures**: Add new Terraform configurations to the `tests/fixtures/` directory, ensuring each has a `main.tf`, `variables.tf`, and `outputs.tf`.
