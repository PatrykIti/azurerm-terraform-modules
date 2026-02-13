# Azure DevOps Elastic Pool Module Tests

This directory contains automated tests for the Azure DevOps Elastic Pool Terraform module using [Terratest](https://terratest.gruntwork.io/).

## Prerequisites

1. **Go**: Version 1.21 or later
2. **Terraform**: Version 1.12.2 or later
3. **Azure DevOps Organization**: Access with a Personal Access Token (PAT)

## Environment Variables

Set the following environment variables before running tests:

```bash
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/your-org"
export AZDO_PERSONAL_ACCESS_TOKEN="your-pat"
export AZDO_TEST_SERVICE_ENDPOINT_ID="00000000-0000-0000-0000-000000000001"
export AZDO_TEST_SERVICE_ENDPOINT_SCOPE="00000000-0000-0000-0000-000000000000"
export AZDO_TEST_AZURE_RESOURCE_ID="/subscriptions/.../resourceGroups/.../providers/Microsoft.Compute/virtualMachineScaleSets/..."
```

## Running Tests

```bash
make test
```

## Test Fixtures

- `fixtures/basic/` - Basic module configuration
- `fixtures/complete/` - Full optional configuration
- `fixtures/secure/` - Security-focused configuration
