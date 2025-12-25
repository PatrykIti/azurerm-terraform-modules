# Storage Account Module Tests

This directory contains native Terraform unit tests and Terratest suites for the Azure Storage Account module.

## Test Structure

```
tests/
├── fixtures/                  # Terraform configurations for integration tests
│   ├── simple/               # Legacy basic fixture (equivalent to "basic")
│   ├── complete/             # Full feature configuration
│   ├── security/             # Legacy secure fixture (equivalent to "secure")
│   ├── network/              # Network rules scenarios
│   ├── private_endpoint/     # Private endpoint scenario
│   ├── negative/             # Validation failures
│   ├── advanced_policies/    # Feature-specific scenario
│   ├── data_lake_gen2/        # Feature-specific scenario
│   ├── identity_access/      # Feature-specific scenario
│   └── multi_region/         # Feature-specific scenario
├── unit/                      # Native Terraform tests (.tftest.hcl)
├── storage_account_test.go    # Main Terratest suite
├── integration_test.go        # Longer-running integration tests
├── performance_test.go        # Performance tests/benchmarks
├── test_helpers.go            # Shared helper functions
├── Makefile                   # Test commands
├── test_config.yaml           # CI configuration
├── test_env.sh                # Local env helper
├── run_tests_parallel.sh      # Parallel runner
├── run_tests_sequential.sh    # Sequential runner
└── test_outputs/              # Test outputs (ignored)
```

> Note: Some fixtures use legacy names (`simple`, `security`). New modules should prefer `basic` and `secure` per `docs/TESTING_GUIDE/`.

## Prerequisites

1. **Azure credentials** (ARM_ or AZURE_):
   ```bash
   export ARM_SUBSCRIPTION_ID="..."   # or AZURE_SUBSCRIPTION_ID
   export ARM_TENANT_ID="..."         # or AZURE_TENANT_ID
   export ARM_CLIENT_ID="..."         # or AZURE_CLIENT_ID
   export ARM_CLIENT_SECRET="..."     # or AZURE_CLIENT_SECRET
   ```
2. **Terraform**: >= 1.12.2
3. **Go**: 1.21+

## Running Tests

### All Terratest suites
```bash
make test
```

### Specific suites
```bash
make test-basic
make test-security
make test-network
make test-private-endpoint
make test-validation
```

### Single test
```bash
make test-single TEST_NAME=TestBasicStorageAccount
```

### Benchmarks
```bash
make benchmark
```

### Unit tests (Terraform native)
```bash
terraform test -test-directory=tests/unit
```

### Validate fixtures
```bash
make validate-fixtures
```

## Notes

- Short tests are standard `Test...` functions; long-running tests are gated with `testing.Short()`.
- Integration and performance tests require live Azure credentials and incur real cloud costs.
