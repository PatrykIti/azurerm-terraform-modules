# Azure DevOps Group Entitlement Module Tests

This directory contains automated tests for the Azure DevOps Group Entitlement Terraform module using [Terratest](https://terratest.gruntwork.io/).

## Prerequisites

1. **Go**: Version 1.21 or later
2. **Terraform**: Version 1.12.2 or later
3. **Azure DevOps Organization**: Access with a Personal Access Token (PAT)

## Environment Variables

Set the following environment variables before running tests:

```bash
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/your-org"
export AZDO_PERSONAL_ACCESS_TOKEN="your-pat"
export AZDO_GROUP_DISPLAY_NAME="ADO Platform Team"
export AZDO_GROUP_ORIGIN="aad"
export AZDO_GROUP_ORIGIN_ID="00000000-0000-0000-0000-000000000000"
```

## Running Tests

```bash
make test
```

## Test Fixtures

- `fixtures/basic/` - Basic selector mode (`display_name`)
- `fixtures/complete/` - Full selector mode (`origin+origin_id`)
- `fixtures/secure/` - Stakeholder-focused entitlement profile
- `fixtures/negative/` - Invalid selector combinations for validation checks
