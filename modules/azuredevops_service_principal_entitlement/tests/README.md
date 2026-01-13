# Azure DevOps Service Principal Entitlement Module Tests

This directory contains automated tests for the Azure DevOps service principal entitlement Terraform module using [Terratest](https://terratest.gruntwork.io/) and native Terraform unit tests.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Environment Variables](#environment-variables)
- [Running Tests](#running-tests)
- [Test Structure](#test-structure)
- [Debugging Tests](#debugging-tests)
- [Create Test Service Principals (Azure CLI)](#create-test-service-principals-azure-cli)
- [Continuous Integration](#continuous-integration)
- [Contributing](#contributing)

## Prerequisites

1. **Go**: Version 1.21 or later
2. **Terraform**: Version 1.12.2 or later
3. **Azure DevOps Organization**: Access with a Personal Access Token (PAT)
4. **Organization scope**: This module operates at the organization level (no project ID required)

## Environment Variables

Set the following environment variables before running tests:

```bash
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/your-org"
export AZDO_PERSONAL_ACCESS_TOKEN="your-pat"
export AZDO_SERVICE_PRINCIPAL_ORIGIN_ID_BASIC="<sp-object-id-basic>"
export AZDO_SERVICE_PRINCIPAL_ORIGIN_ID_COMPLETE="<sp-object-id-complete>"
export AZDO_SERVICE_PRINCIPAL_ORIGIN_ID_SECURE="<sp-object-id-secure>"
```

Notes:

- Use the **service principal object ID** (`origin_id`), not the appId/clientId.
- For parallel tests, use three distinct service principals.

## Running Tests

### Install Dependencies

```bash
go mod download
```

### Run All Tests

```bash
make test
```

### Run Basic Tests Only

```bash
make test-basic
```

### Run Integration Tests Only

```bash
make test-integration
```

### Run Terraform Unit Tests

```bash
make unit
```

## Test Structure

### Test Files

- `azuredevops_service_principal_entitlement_test.go` - Basic, complete, secure, and validation tests
- `integration_test.go` - Full apply test using the complete fixture
- `performance_test.go` - Benchmarks are disabled by default

### Test Fixtures

The `fixtures/` directory contains Terraform configurations for different test scenarios:

- `fixtures/basic/` - Basic module configuration
- `fixtures/complete/` - Explicit license settings
- `fixtures/secure/` - Security-focused configuration
- `fixtures/negative/` - Negative test cases

## Debugging Tests

### Verbose Output

```bash
go test -v -run TestBasicAzuredevopsServicePrincipalEntitlement
```

### Keep Resources After Test Failure

Set the `SKIP_TEARDOWN` environment variable:

```bash
export SKIP_TEARDOWN=true
go test -v -run TestBasicAzuredevopsServicePrincipalEntitlement
```

## Create Test Service Principals (Azure CLI)

The script below creates three Azure AD service principals and prints their **object IDs**.
Use these values for `AZDO_SERVICE_PRINCIPAL_ORIGIN_ID_*`.

```bash
set -euo pipefail

prefix="ado-sp-ent"
suffix="$(date +%Y%m%d%H%M%S)"

APP_BASIC=$(az ad app create \
  --display-name "${prefix}-basic-${suffix}" \
  --sign-in-audience AzureADMyOrg \
  --query appId -o tsv)
az ad sp create --id "$APP_BASIC" >/dev/null
SP_BASIC=$(az ad sp show --id "$APP_BASIC" --query id -o tsv)

APP_COMPLETE=$(az ad app create \
  --display-name "${prefix}-complete-${suffix}" \
  --sign-in-audience AzureADMyOrg \
  --query appId -o tsv)
az ad sp create --id "$APP_COMPLETE" >/dev/null
SP_COMPLETE=$(az ad sp show --id "$APP_COMPLETE" --query id -o tsv)

APP_SECURE=$(az ad app create \
  --display-name "${prefix}-secure-${suffix}" \
  --sign-in-audience AzureADMyOrg \
  --query appId -o tsv)
az ad sp create --id "$APP_SECURE" >/dev/null
SP_SECURE=$(az ad sp show --id "$APP_SECURE" --query id -o tsv)

export AZDO_SERVICE_PRINCIPAL_ORIGIN_ID_BASIC="$SP_BASIC"
export AZDO_SERVICE_PRINCIPAL_ORIGIN_ID_COMPLETE="$SP_COMPLETE"
export AZDO_SERVICE_PRINCIPAL_ORIGIN_ID_SECURE="$SP_SECURE"

echo "BASIC   SP Object ID: $SP_BASIC"
echo "COMPLETE SP Object ID: $SP_COMPLETE"
echo "SECURE  SP Object ID: $SP_SECURE"

# Optional cleanup after tests:
# az ad app delete --id "$APP_BASIC"
# az ad app delete --id "$APP_COMPLETE"
# az ad app delete --id "$APP_SECURE"
```

If you see transient AAD errors right after creation, wait ~30 seconds and retry the `az ad sp show` call.

## Continuous Integration

Tests are automatically run in CI/CD pipelines:

- **Pull Requests**: Short tests only
- **Main Branch**: All tests including integration

## Contributing

When adding new tests:

1. Follow the existing test structure and naming conventions
2. Add appropriate fixtures in the `fixtures/` directory
3. Keep tests idempotent and clean up resources
