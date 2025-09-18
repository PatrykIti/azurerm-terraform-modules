# Troubleshooting Guide

This guide provides solutions to common issues encountered while running Terratest integration tests for the modules in this repository.

## Common Issues and Solutions

### 1. Authentication Errors

**Symptom:** The test fails during `terraform init` or `apply` with an error related to authentication, credentials, or authorization.

**Error Message Examples:**
- `Error: building AzureRM Client: ... invalid_client_secret ...`
- `Error: ... does not have authorization to perform action 'Microsoft.Resources/subscriptions/resourcegroups/read' ...`

**Solution:**

1.  **Check Environment Variables**: Ensure that the required environment variables for authentication are correctly set and exported in your shell. The required variables are:
    - `AZURE_CLIENT_ID`
    - `AZURE_CLIENT_SECRET`
    - `AZURE_TENANT_ID`
    - `AZURE_SUBSCRIPTION_ID`
    
    You can use the `test_env.sh` script as a template, but **never commit it with real credentials**.

2.  **Verify Service Principal Permissions**: The Service Principal used for testing must have the `Contributor` role on the target Azure subscription.

3.  **Check for Local Azure CLI Login**: If you are running tests locally without setting the environment variables, make sure you are logged in with the Azure CLI (`az login`) and have selected the correct subscription (`az account set --subscription <subscription_id>`).

### 2. Resource Naming Conflicts

**Symptom:** `terraform apply` fails with an error indicating that a resource with a given name already exists.

**Error Message Example:**
- `Error: A resource with the specified name already exists.`
- `Error: StorageAccountAlreadyTaken: The storage account named '...' is already taken.`

**Solution:**

1.  **Run Cleanup**: The tests are designed to use a `random_suffix` to prevent this, but interrupted test runs can leave orphaned resources. Run `make clean` to delete local temporary files.
2.  **Manual Azure Cleanup**: If the conflict is with a resource in Azure that was not properly deleted, you may need to manually delete the resource or the entire test resource group from the Azure portal. Test resource groups are typically named `rg-test-<random_suffix>`.

### 3. Test Timeouts

**Symptom:** The test fails with a timeout error, often during a long `terraform apply` or `destroy` operation.

**Solution:**

-   **Increase Timeout via Makefile**: You can override the default timeout by passing the `TIMEOUT` variable to the `make` command. The default is `30m`.
    ```bash
    # Increase the timeout to 45 minutes
    make test TIMEOUT=45m
    ```

### 4. Terraform State Lock Errors

**Symptom:** `terraform apply` fails with an error about failing to acquire a state lock.

**Error Message Example:**
- `Error: Error acquiring the state lock ... Lock Info: ...`

**Solution:**

-   This typically happens during local development if a previous test run was interrupted. The `make clean` command should remove the local `.tfstate` and `.terraform` directories, which usually resolves the issue. If the problem persists, you may need to manually delete the `.terraform.lock.hcl` file from the temporary test directory.

## Debugging Techniques

### Running a Single Test

To focus on a specific failing test, use the `test-single` target in the `Makefile`. This is much faster than running the entire suite.

```bash
# Run only the TestStorageAccountPrivateEndpoint test
make test-single TEST_NAME=TestStorageAccountPrivateEndpoint
```

### Disabling Parallel Execution

While parallel execution is fast, the interleaved logs can be hard to read. To run tests sequentially, set the `PARALLEL` variable to `1`.

```bash
# Run all tests sequentially
make test PARALLEL=1
```

### Inspecting Terraform Logs

Terratest executes Terraform commands in the background. To see the detailed output of a failing `apply` or `plan`, you can temporarily modify the Go test file to log the output.

```go
// In a Go test file, for debugging purposes
terraformOptions := getTerraformOptions(t, testFolder)

// This will print the full plan to the console
planResult := terraform.InitAndPlan(t, terraformOptions)
t.Log(planResult)

// To see the full output of an apply command
output, err := terraform.InitAndApplyE(t, terraformOptions)
t.Log(output)
require.NoError(t, err)
```

### Keeping Test Resources After a Run

By default, all tests use a `defer` block to run `terraform destroy`. To inspect the created resources in Azure after a test run, you can temporarily comment out the `defer` block in the relevant Go test function.

```go
func TestBasicStorageAccount(t *testing.T) {
    // ...
    
    // Temporarily comment out the cleanup stage for debugging
    // defer test_structure.RunTestStage(t, "cleanup", func() {
    //     terraform.Destroy(t, getTerraformOptions(t, testFolder))
    // })

    // ...
}
```
**Warning**: Remember to uncomment this line after debugging to prevent orphaned resources and unnecessary costs.
