# Helper Pattern and Validation Functions

The `test_helpers.go` file is the foundation of reusability and readability in our integration tests. Instead of placing Azure SDK interaction logic and repetitive code snippets directly in test files, we centralize them in helpers. The standard pattern and best practices are described below.

## Helper Class Pattern

For each module being tested, we create a dedicated helper struct (class) that encapsulates the logic specific to that resource.

### Struct Definition

The struct stores authenticated Azure SDK clients and other necessary information, such as the subscription ID.

**Example (`test_helpers.go` for `azurerm_storage_account`):**
```go
// StorageAccountHelper provides helper methods for storage account testing
type StorageAccountHelper struct {
	subscriptionID string
	credential     azcore.TokenCredential
	client         *armstorage.AccountsClient
	blobClient     *armstorage.BlobServicesClient
}
```
-   `subscriptionID`: Stores the subscription ID to avoid reading it from environment variables multiple times.
-   `credential`: Stores the `TokenCredential` object from the Azure SDK, used to authenticate all clients.
-   `client`, `blobClient`: Store instances of resource-specific SDK clients (in this case, `AccountsClient` and `BlobServicesClient`).

### Helper Initialization

The `New...Helper` factory function is responsible for:
1.  Reading the necessary environment variables.
2.  Creating a `credential` object (handling different authentication methods).
3.  Initializing all required SDK clients.
4.  Returning a fully configured helper instance.

```go
// NewStorageAccountHelper creates a new helper instance
func NewStorageAccountHelper(t *testing.T) *StorageAccountHelper {
	subscriptionID := getRequiredEnvVar(t, "AZURE_SUBSCRIPTION_ID")
	
	// Authentication logic (Service Principal, Azure CLI, Default)
	credential, err := azidentity.NewDefaultAzureCredential(nil)
	require.NoError(t, err, "Failed to create credential")

	// Initialize clients
	client, err := armstorage.NewAccountsClient(subscriptionID, credential, nil)
	require.NoError(t, err, "Failed to create storage accounts client")
	
	blobClient, err := armstorage.NewBlobServicesClient(subscriptionID, credential, nil)
	require.NoError(t, err, "Failed to create blob services client")

	return &StorageAccountHelper{
		subscriptionID: subscriptionID,
		credential:     credential,
		client:         client,
		blobClient:     blobClient,
	}
}
```

## Validation Functions

Validation methods are a key part of the helper. Their task is to verify that the deployed resource has the expected configuration.

### Best Practices
-   **Single Responsibility**: Each function should validate one logical aspect of the resource (e.g., encryption, network rules).
-   **Accept a Resource Object**: Functions should accept a resource object retrieved from the Azure SDK (e.g., `armstorage.Account`) as an argument, not just its name. This reduces the number of API calls.
-   **Use `require` and `assert`**: Use `require` for critical assertions that must be met to continue the test (e.g., `require.NotNil`). Use `assert` for other checks.
-   **Clear Error Messages**: Every assertion should have a clear message explaining what went wrong.

### Examples of Validation Functions

#### Encryption Validation
```go
// ValidateStorageAccountEncryption validates encryption settings
func (h *StorageAccountHelper) ValidateStorageAccountEncryption(t *testing.T, account armstorage.Account) {
	require.NotNil(t, account.Properties.Encryption, "Encryption should be configured")
	require.Equal(t, armstorage.KeySourceMicrosoftStorage, *account.Properties.Encryption.KeySource, "Should use Microsoft managed keys")
	
	// Validate blob encryption
	require.NotNil(t, account.Properties.Encryption.Services.Blob, "Blob encryption should be configured")
	assert.True(t, *account.Properties.Encryption.Services.Blob.Enabled, "Blob encryption should be enabled")
}
```

#### Network Rule Validation
```go
// ValidateNetworkRules validates network access rules
func (h *StorageAccountHelper) ValidateNetworkRules(t *testing.T, account armstorage.Account, expectedIPRules []string) {
	require.NotNil(t, account.Properties.NetworkRuleSet, "Network rules should be configured")
	assert.Equal(t, armstorage.DefaultActionDeny, *account.Properties.NetworkRuleSet.DefaultAction)
	
	// Validate IP rules
	require.Equal(t, len(expectedIPRules), len(account.Properties.NetworkRuleSet.IPRules), "IP rules count mismatch")
	
	actualIPRules := make([]string, 0)
	for _, rule := range account.Properties.NetworkRuleSet.IPRules {
		actualIPRules = append(actualIPRules, *rule.IPAddressOrRange)
	}
	
	for _, expectedIP := range expectedIPRules {
		require.Contains(t, actualIPRules, expectedIP, "Expected IP rule not found")
	}
}
```

## Waiter Functions

Some operations in Azure are asynchronous. Waiter functions use the `retry` mechanism from Terratest to periodically check the state of a resource until it reaches the desired state or a timeout occurs.

```go
// WaitForGRSSecondaryEndpoints waits for GRS secondary endpoints to be available
func (h *StorageAccountHelper) WaitForGRSSecondaryEndpoints(t *testing.T, accountName, resourceGroupName string) {
	description := fmt.Sprintf("Waiting for GRS secondary endpoints for storage account %s", accountName)
	
	retry.DoWithRetry(t, description, 60, 10*time.Second, func() (string, error) {
		account := h.GetStorageAccountProperties(t, accountName, resourceGroupName)
		
		if account.Properties.SecondaryEndpoints != nil && account.Properties.SecondaryEndpoints.Blob != nil && *account.Properties.SecondaryEndpoints.Blob != "" {
			return "GRS secondary endpoints are available", nil
		}
		
		return "", fmt.Errorf("GRS secondary endpoints are not yet available")
	})
}
```
-   `retry.DoWithRetry`: A function from Terratest.
-   `description`: A readable message logged during each attempt.
-   `60`: The maximum number of attempts.
-   `10*time.Second`: The time to wait between attempts.
-   The anonymous function contains the checking logic. It returns `nil` as an error if the condition is met, which ends the loop.

## General Helper Functions

In addition to methods in the helper, the `test_helpers.go` file also contains global helper functions.

### `terraform.Options` Factory

The `getTerraformOptions` function centralizes the creation of Terratest configurations, ensuring consistency.

```go
// getTerraformOptions helper function to get terraform options
func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	randomSuffix := strings.ToLower(random.UniqueId())
	
	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"random_suffix": randomSuffix,
			"location":      "northeurope",
		},
		NoColor: true,
		// Retry configuration for transient errors
		RetryableTerraformErrors: map[string]string{
			".*timeout.*":                    "Timeout error - retrying",
			".*ResourceGroupNotFound.*":      "Resource group not found - retrying",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10 * time.Second,
	}
}
```
-   **Unique Names**: Automatically generates a `random_suffix` and passes it to Terraform variables.
-   **Retry Configuration**: Defines which Terraform errors should be retried (e.g., network issues, `Eventually Consistent` errors).

### Reading Environment Variables

```go
// getRequiredEnvVar gets a required environment variable or fails the test
func getRequiredEnvVar(t *testing.T, envVarName string) string {
	value := os.Getenv(envVarName)
	require.NotEmpty(t, value, fmt.Sprintf("Required environment variable %s is not set", envVarName))
	return value
}
```
This simple function ensures that the test will fail if a key environment variable is missing, rather than continuing with unpredictable errors.
