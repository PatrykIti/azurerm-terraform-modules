# Application Insights Workbook Module Tests

This directory contains Terratest and Terraform unit tests for
`azurerm_application_insights_workbook`.

## Prerequisites

- Go 1.21+
- Terraform 1.12.2+
- Azure credentials via either `ARM_*` or `AZURE_*` variables

## Environment Variables

Set one of the equivalent credential sets:

```bash
# Preferred
export ARM_SUBSCRIPTION_ID="<subscription-id>"
export ARM_TENANT_ID="<tenant-id>"
export ARM_CLIENT_ID="<client-id>"
export ARM_CLIENT_SECRET="<client-secret>"
export ARM_LOCATION="westeurope"   # optional

# Fallback aliases also supported
export AZURE_SUBSCRIPTION_ID="$ARM_SUBSCRIPTION_ID"
export AZURE_TENANT_ID="$ARM_TENANT_ID"
export AZURE_CLIENT_ID="$ARM_CLIENT_ID"
export AZURE_CLIENT_SECRET="$ARM_CLIENT_SECRET"
export AZURE_LOCATION="$ARM_LOCATION"
```

## Canonical Commands

```bash
# Run full Terratest suite via tests harness
make test

# Targeted suites
make test-basic
make test-complete
make test-secure
make test-validation
make test-integration
make test-performance
make benchmark

# Harness scripts (JSON/log outputs under test_outputs/)
make test-script-parallel
make test-script-sequential
```

## Test Structure

### Test files

- `application_insights_workbook_test.go` - primary fixture tests
- `integration_test.go` - integration/lifecycle tests
- `performance_test.go` - performance tests + benchmarks
- `test_helpers.go` - helper utilities
- `test_config.yaml` - CI-oriented suite metadata

### Fixtures

- `fixtures/basic/` - minimal required inputs
- `fixtures/complete/` - full features including `source_id`, `storage_container_id`, identity
- `fixtures/secure/` - user-assigned identity and RBAC example
- `fixtures/workbook-identity/` - identity-focused case
- `fixtures/negative/` - validation failure fixture

## Debugging

```bash
go test -v -run TestCompleteApplicationInsightsWorkbook
export SKIP_TEARDOWN=true
export TF_LOG=DEBUG
```
