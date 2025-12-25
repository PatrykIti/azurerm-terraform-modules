# Route Table Module Tests

This directory contains automated tests for the Route Table Terraform module,
aligned with the repository [Testing Guide](../../../docs/TESTING_GUIDE/README.md).

## Prerequisites

1. **Go**: Version 1.21 or later (see `go.mod`)
2. **Terraform**: Version 1.12.2 or later
3. **Azure CLI**: Authenticated with appropriate permissions
4. **Azure Service Principal**: Contributor access to the test subscription

## Environment Variables

The test helpers use standard Azure credentials. You can set either `AZURE_*`
or `ARM_*`. Terraform uses `ARM_*`.

```bash
export AZURE_CLIENT_ID="your-client-id"
export AZURE_CLIENT_SECRET="your-client-secret"
export AZURE_SUBSCRIPTION_ID="your-subscription-id"
export AZURE_TENANT_ID="your-tenant-id"

# Map to ARM_ variables for Terraform
export ARM_CLIENT_ID="${AZURE_CLIENT_ID}"
export ARM_CLIENT_SECRET="${AZURE_CLIENT_SECRET}"
export ARM_SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID}"
export ARM_TENANT_ID="${AZURE_TENANT_ID}"

# Optional
export ARM_LOCATION="northeurope"
```

## Running Tests

All commands should be executed from within this `tests` directory.

**Install dependencies:**
```bash
make deps
```

**Run all tests:**
```bash
make test
```

**Run specific suites:**
```bash
make test-basic
make test-complete
make test-secure
make test-network
make test-validation
make test-integration
make test-performance
```

**Run a single test:**
```bash
make test-single TEST_NAME=TestBasicRouteTable
```

**Benchmarks:**
```bash
make benchmark
```

## Test Structure

```
tests/
├── fixtures/                # Terraform configurations for test scenarios
│   ├── basic/
│   ├── complete/
│   ├── secure/
│   ├── network/
│   └── negative/
├── unit/                    # Native Terraform tests (.tftest.hcl)
├── route_table_test.go      # Main module tests
├── integration_test.go      # Lifecycle and integration tests
├── performance_test.go      # Performance tests
├── test_helpers.go          # Helper utilities
└── Makefile                 # Test runner
```

## Troubleshooting

- **Auth errors**: verify `ARM_*` or `AZURE_*` variables and RBAC.
- **Resource conflicts**: ensure unique resource names in fixtures.
- **Timeouts**: increase `TIMEOUT` in `Makefile` or via env.
