# Terratest Integration (Integration Tests)

Integration tests are the third level of the testing pyramid and are crucial for verifying that Terraform modules correctly create and configure real infrastructure in Azure. For this purpose, we use the **Terratest** framework, written in Go.

## When to Use Terratest?

Terratest is the ideal tool for scenarios that cannot be verified with static analysis or unit tests. Key use cases include:

- ✅ **Deployment Verification**: Checking if resources were created with the correct properties (SKU, location, name).
- ✅ **Network Rule Testing**: Verifying that NSG rules, firewalls, or private endpoints work as expected.
- ✅ **IAM Permission Validation**: Checking if assigned roles and permissions (RBAC) allow for the intended actions.
- ✅ **Resource Interaction Testing**: Verifying if, for example, a virtual machine can connect to a database via a private link.
- ✅ **Azure Policy Compliance Checking**: Verifying that the deployed infrastructure complies with assigned policies.

## Required Tools and Dependencies

To run integration tests, the development environment must be equipped with:

1.  **Go**: Version 1.21 or newer.
2.  **Terraform**: Version 1.5.0 or newer.
3.  **Azure CLI**: For authentication and interaction with Azure.
4.  **Key Go Packages**: Dependencies are managed by `go.mod`.

### Main Dependencies in `go.mod`

The `go.mod` file in the `tests` directory defines key libraries. The most important ones are:

```go
module github.com/example/azurerm-storage-account/tests

go 1.21

require (
	github.com/Azure/azure-sdk-for-go/sdk/azcore v1.9.0
	github.com/Azure/azure-sdk-for-go/sdk/azidentity v1.4.0
	github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/storage/armstorage v1.5.0
	github.com/gruntwork-io/terratest v0.46.7
	github.com/stretchr/testify v1.8.4
)
```

-   **`github.com/gruntwork-io/terratest`**: The main framework for infrastructure testing. It provides functions to run Terraform commands (`terraform init`, `apply`, `destroy`) and validate the results.
-   **`github.com/stretchr/testify`**: A popular assertion package in Go. We use it to check conditions (e.g., `assert.Equal`, `require.NoError`).
-   **`github.com/Azure/azure-sdk-for-go/sdk/*`**: The new Azure SDK for Go. We use it for direct interaction with the Azure API to verify the state of resources after they are created by Terraform.

## Authentication

Terratest tests require authentication with Azure. Our scripts and helpers support several methods, which are used in the following order:

1.  **Service Principal (Environment Variables)**: The preferred method in CI/CD.
    - `AZURE_CLIENT_ID`
    - `AZURE_CLIENT_SECRET`
    - `AZURE_TENANT_ID`
    - `AZURE_SUBSCRIPTION_ID`
2.  **Azure CLI**: The default method for local development if the above variables are not set. You just need to be logged in via `az login`.
3.  **Default Azure Credential**: The final method, which tries various mechanisms (Managed Identity, etc.).

The `test_env.sh` file is used to set these variables locally. **You should never commit real credentials to the version control system.**

```bash
# modules/azurerm_storage_account/tests/test_env.sh
#!/bin/bash
# Azure credentials for testing
export AZURE_CLIENT_ID="YOUR_AZURE_CLIENT_ID_HERE"
export AZURE_CLIENT_SECRET="YOUR_AZURE_CLIENT_SECRET_HERE"
export AZURE_SUBSCRIPTION_ID="YOUR_AZURE_SUBSCRIPTION_ID_HERE"
export AZURE_TENANT_ID="YOUR_AZURE_TENANT_ID_HERE"

# ARM_ prefixed variables for Terraform provider
export ARM_CLIENT_ID="${AZURE_CLIENT_ID}"
export ARM_CLIENT_SECRET="${AZURE_CLIENT_SECRET}"
export ARM_SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID}"
export ARM_TENANT_ID="${AZURE_TENANT_ID}"
```

## Basic Test Lifecycle

Every integration test with Terratest follows this pattern:

1.  **Setup**:
    - The test copies the appropriate Terraform configuration (a `fixture`) to a temporary directory.
    - Unique names for resources are generated to avoid conflicts during parallel test execution.
2.  **Deploy**:
    - `terraform init` and `terraform apply` commands are run to deploy the infrastructure.
3.  **Validate**:
    - Output values are read from the deployed configuration.
    - The state and configuration of the deployed resources are checked using the Azure SDK and assertions.
4.  **Cleanup**:
    - The `terraform destroy` command is run to remove all resources created during the test. This step is always executed, even if the test fails, thanks to the use of `defer`.

This cycle ensures that tests are **isolated**, **repeatable**, and **do not leave behind unnecessary resources**, which is crucial for cost control.
