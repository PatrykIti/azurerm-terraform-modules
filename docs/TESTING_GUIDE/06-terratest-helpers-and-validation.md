# Helper Pattern and Validation Functions

The `test_helpers.go` file is the cornerstone of our integration testing strategy. It promotes the Don't Repeat Yourself (DRY) principle by centralizing all Azure SDK interactions, validation logic, and other utility functions. This keeps the main `*_test.go` files clean, readable, and focused on orchestrating test scenarios.

## The Helper Class Pattern

For each module, we create a dedicated Go struct that acts as a "helper." This struct encapsulates the clients and methods needed to interact with and validate the specific Azure resources created by the module.

### 1. Helper Struct Definition

The struct holds authenticated Azure SDK clients and any other shared information, like the subscription ID.

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
-   `subscriptionID`: Caches the subscription ID to avoid repeated lookups.
-   `credential`: Stores the `azcore.TokenCredential` used for authenticating all SDK clients.
-   `client`, `blobClient`, etc.: Instances of the specific SDK clients needed to manage the resource (e.g., `AccountsClient` for the storage account itself, `BlobServicesClient` for its blob properties).

### 2. Helper Factory Function

A `New...Helper` factory function is responsible for creating and initializing a ready-to-use helper instance.

**Key Responsibilities:**
1.  Read required environment variables (e.g., `AZURE_SUBSCRIPTION_ID`).
2.  Handle authentication, preferring CI/CD-friendly Service Principal credentials but falling back to `AzureCLICredential` for local development.
3.  Initialize all necessary Azure SDK clients.
4.  Return the fully configured helper struct.

**Example (`NewStorageAccountHelper`):**
```go
// NewStorageAccountHelper creates a new helper instance
func NewStorageAccountHelper(t *testing.T) *StorageAccountHelper {
	subscriptionID := getRequiredEnvVar(t, "AZURE_SUBSCRIPTION_ID")
	
	// Standard authentication logic
	credential, err := azidentity.NewDefaultAzureCredential(nil)
	require.NoError(t, err, "Failed to create default credential")

	// Initialize the required clients
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

## Validation Methods

Validation methods are attached to the helper struct. They contain the logic to verify that a deployed resource is configured as expected.

**Best Practices:**
-   **Single Responsibility**: Each function should validate one logical aspect (e.g., encryption, network rules, tags).
-   **Accept the SDK Object**: To minimize API calls, functions should accept the `armstorage.Account` (or similar) object, which is fetched once in the main test function.
-   **Use `require` and `assert`**: Use `require` for fatal assertions that stop the test if they fail (e.g., the resource object is `nil`). Use `assert` for non-fatal checks.
-   **Provide Clear Error Messages**: Every assertion must have a descriptive message.

### Example: Encryption Validation
```go
// ValidateStorageAccountEncryption validates encryption settings
func (h *StorageAccountHelper) ValidateStorageAccountEncryption(t *testing.T, account armstorage.Account) {
	require.NotNil(t, account.Properties.Encryption, "Encryption properties should not be nil")
	
	// Assert that Microsoft Managed Keys are used
	require.Equal(t, armstorage.KeySourceMicrosoftStorage, *account.Properties.Encryption.KeySource, "Key source should be Microsoft.Storage")
	
	// Assert that blob service encryption is enabled
	require.NotNil(t, account.Properties.Encryption.Services.Blob, "Blob encryption service should be configured")
	assert.True(t, *account.Properties.Encryption.Services.Blob.Enabled, "Blob encryption should be enabled")
}
```

## Waiter Functions

Azure operations can be asynchronous. Waiter functions use Terratest's `retry` package to poll a resource until it reaches a desired state.

### Example: Wait for GRS Replication
```go
// WaitForGRSSecondaryEndpoints waits for GRS secondary endpoints to be available
func (h *StorageAccountHelper) WaitForGRSSecondaryEndpoints(t *testing.T, accountName, resourceGroupName string) {
	description := fmt.Sprintf("Waiting for GRS secondary endpoints for %s", accountName)
	
	// Poll for up to 10 minutes (60 attempts * 10 seconds)
	retry.DoWithRetry(t, description, 60, 10*time.Second, func() (string, error) {
		account := h.GetStorageAccountProperties(t, accountName, resourceGroupName)
		
		if account.Properties.SecondaryEndpoints != nil && account.Properties.SecondaryEndpoints.Blob != nil && *account.Properties.SecondaryEndpoints.Blob != "" {
			return "GRS secondary endpoints are available.", nil
		}
		
		return "", fmt.Errorf("GRS secondary endpoints are not yet available")
	})
}
```

## General Utility Functions

The `test_helpers.go` file also contains standalone utility functions that are not tied to the helper struct.

### `getTerraformOptions` Factory

This is one of the most important utility functions. It centralizes the creation of `terraform.Options` to ensure all tests are run with a consistent configuration.

```go
// getTerraformOptions creates a standard terraform.Options object
func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	// Generate a unique suffix for resource names to allow parallel execution
	randomSuffix := strings.ToLower(random.UniqueId())
	
	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"random_suffix": randomSuffix,
			"location":      "northeurope", // Standard test location
		},
		NoColor: true,
		// Configure retries for common transient Azure errors
		RetryableTerraformErrors: map[string]string{
			".*ResourceGroupNotFound.*":      "Resource group not found, retrying.",
			".*StorageAccountAlreadyTaken.*": "Storage account name taken, retrying.",
			".*timeout.*":                    "Timeout error, retrying.",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10 * time.Second,
	}
}
```

### `getRequiredEnvVar`

This utility ensures that tests fail fast if the required environment variables for authentication are not set.

```go
// getRequiredEnvVar gets a required environment variable or fails the test
func getRequiredEnvVar(t *testing.T, envVarName string) string {
	value := os.Getenv(envVarName)
	require.NotEmpty(t, value, fmt.Sprintf("Required environment variable '%s' is not set.", envVarName))
	return value
}
```