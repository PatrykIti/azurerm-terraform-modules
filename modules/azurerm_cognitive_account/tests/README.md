# Cognitive Account Module Tests

This directory contains Terratest and Terraform unit tests for `modules/azurerm_cognitive_account`.

## Prerequisites

1. **Go**: 1.21+
2. **Terraform**: 1.12.2+
3. **Azure credentials**: service principal with permissions to create/destroy test resources

## Environment Variables

Set either `ARM_*` or `AZURE_*` credentials before running integration/performance tests:

```bash
export ARM_SUBSCRIPTION_ID="..."
export ARM_TENANT_ID="..."
export ARM_CLIENT_ID="..."
export ARM_CLIENT_SECRET="..."
export ARM_LOCATION="swedencentral" # optional
```

## Install Dependencies

```bash
make deps
```

## Common Commands

```bash
# Compile gate (no test execution)
go test ./... -run '^$'

# Run all Go tests
make test

# Targeted suites
make test-basic
make test-complete
make test-secure
make test-network
make test-private-endpoint
make test-validation
make test-integration
make test-performance

# Benchmark suite
make benchmark

# Terraform fixture validation
make validate-fixtures
```

## Test Files

- `cognitive_account_test.go` - core module tests and validation tests
- `integration_test.go` - cross-feature integration/lifecycle tests
- `performance_test.go` - benchmarks and performance assertions
- `test_helpers.go` - shared test helpers
- `test_config.yaml` - scenario metadata used by scripts/runbooks

## Fixtures

Current fixture directories under `tests/fixtures/`:

- `openai-basic/`
- `openai-complete/`
- `openai-secure/`
- `language-basic/`
- `speech-basic/`
- `basic/`
- `complete/`
- `secure/`
- `network/`
- `negative/`

Private endpoint tests use `openai-secure/` (there is no `fixtures/private_endpoint/`).

## Notes

- Integration/performance tests create real Azure resources and can take significant time.
- Keep `SKIP_TEARDOWN=true` only for debugging; otherwise resources should be destroyed automatically.
- QA guardrail for generated example artifacts:
  - `find ../examples -type d -name '.terraform' -o -type f -name '.terraform.lock.hcl'`
