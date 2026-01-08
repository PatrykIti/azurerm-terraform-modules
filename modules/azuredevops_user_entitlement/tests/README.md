# Azure DevOps User Entitlement Tests

This directory contains unit tests for the module using `terraform test`.

## Prerequisites

- Terraform 1.12.2+
- Azure DevOps provider 1.12.2+

## Environment

Set required Azure DevOps variables before running tests (if needed for future integration tests):

```bash
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/your-org"
export AZDO_PERSONAL_ACCESS_TOKEN="your-pat"
```

## Running tests

```bash
terraform test -test-directory=./unit
```

or

```bash
make test
```

## Structure

- `unit/` – native Terraform unit tests (`.tftest.hcl`).
- `fixtures/` – Terraform fixtures for future integration tests (none required yet).

## Notes

No Go-based Terratest integration is provided for this module; extend as needed following the repo template.
