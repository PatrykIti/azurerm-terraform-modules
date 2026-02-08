# Private DNS Zone Module Tests

This directory contains test automation for `modules/azurerm_private_dns_zone`.

## Test Layers

1. `terraform test` unit checks in `tests/unit/*.tftest.hcl` using mocked providers (no Azure deployment).
2. Terratest integration/lifecycle checks in Go (`*_test.go`) against Azure fixtures.

## Baseline Versions

- Terraform: `>= 1.12.2`
- AzureRM provider: `4.57.0` (pinned)
- Go: `1.21`

## Fixtures In Scope

- `fixtures/basic`
- `fixtures/complete`
- `fixtures/secure`
- `fixtures/negative`

`fixtures/network` was removed from active inventory because `azurerm_private_dns_zone` does not support `location` or `network_rules` arguments.

## Terratest Credentials

Set one credential family before running Terratest:

```bash
export ARM_SUBSCRIPTION_ID="<subscription>"
export ARM_TENANT_ID="<tenant>"
export ARM_CLIENT_ID="<client-id>"
export ARM_CLIENT_SECRET="<client-secret>"
export ARM_LOCATION="northeurope" # optional
```

Equivalent `AZURE_*` variables are also accepted by the test Makefile.

## Commands

Compile-only Go test pass (no tests executed):

```bash
go test ./... -run '^$'
```

Run Terratest functional suite:

```bash
go test -v -timeout 60m -run 'TestBasicPrivateDnsZone|TestCompletePrivateDnsZone|TestSecurePrivateDnsZone|TestPrivateDnsZoneValidationRules|TestPrivateDnsZoneIntegration' ./...
```

Run Terraform unit tests:

```bash
terraform test -test-directory=tests/unit
```

Run performance-focused tests (opt-in):

```bash
go test -v -timeout 60m -run 'TestPrivateDnsZoneCreationTime|TestPrivateDnsZoneScaling|TestPrivateDnsZoneUpdatePerformance|TestPrivateDnsZoneDestroyPerformance' ./...
```

## Test Inventory

- `private_dns_zone_test.go`: main Terratest lifecycle and validation coverage.
- `integration_test.go`: integration coverage statement and fixture-scope guard.
- `performance_test.go`: performance and scaling checks (not default for fast validation).
- `unit/*.tftest.hcl`: module input/output/default validation under mocked provider.

## Notes

- `TestPrivateDnsZoneIntegration` does not provision resources itself; it documents and guards that integration coverage is provided by `TestBasicPrivateDnsZone`, `TestCompletePrivateDnsZone`, and `TestSecurePrivateDnsZone`.
- Keep fixture configuration aligned with the module's supported arguments only.
