# Event Hub Module Tests

Terratest suite for `modules/azurerm_eventhub`.

## Prerequisites

- Go 1.21+
- Terraform 1.12.2+
- Azure credentials exported as `ARM_*` or `AZURE_*`

## Required Environment Variables

```bash
export ARM_SUBSCRIPTION_ID="<subscription-id>"
export ARM_TENANT_ID="<tenant-id>"
export ARM_CLIENT_ID="<client-id>"
export ARM_CLIENT_SECRET="<client-secret>"
```

## Quick Commands

```bash
# compile gate (no tests executed)
go test ./... -run '^$'

# run full suite via Makefile
make test

# targeted suites
make test-basic
make test-complete
make test-secure
make test-network
make test-validation
make test-integration
make test-performance
```

## Test Files

- `eventhub_test.go` - core module scenarios and validation tests
- `integration_test.go` - cross-scenario integration flows
- `performance_test.go` - timing/benchmark-oriented tests
- `test_helpers.go` - shared helpers and configuration
- `test_config.yaml` - test metadata/configuration

## Fixtures

- `fixtures/basic`
- `fixtures/complete`
- `fixtures/secure`
- `fixtures/network`
- `fixtures/capture`
- `fixtures/consumer_groups`
- `fixtures/negative`

## Logging

Make targets that run tests use `run_with_log` and write logs to `tests/test_outputs/*.log`.
