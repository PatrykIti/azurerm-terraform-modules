# Helper Pattern and Validation Functions

The `test_helpers.go` file is the cornerstone of our integration testing strategy. It promotes the Don't Repeat Yourself (DRY) principle by centralizing all Azure SDK interactions, validation logic, and other utility functions. This keeps the main `*_test.go` files clean, readable, and focused on orchestrating test scenarios.

## The Helper Class Pattern

For each module, we create a dedicated Go struct that acts as a "helper." This struct encapsulates the clients and methods needed to interact with and validate the specific Azure resources created by the module.

### 1. Helper Struct Definition

The struct holds authenticated Azure SDK clients and any other shared information, like the subscription ID.

**Example (`test_helpers.go` for `azurerm_kubernetes_cluster`):**
```go
// KubernetesClusterHelper provides helper methods for AKS testing
type KubernetesClusterHelper struct {
	subscriptionID string
	credential     azcore.TokenCredential
	client         *armcontainerservice.ManagedClustersClient
}
```
-   `subscriptionID`: Caches the subscription ID to avoid repeated lookups.
-   `credential`: Stores the `azcore.TokenCredential` used for authenticating all SDK clients.
-   `client`: Instances of the specific SDK clients needed to manage the resource (e.g., `ManagedClustersClient` for AKS).

### 2. Helper Factory Function

A `New...Helper` factory function is responsible for creating and initializing a ready-to-use helper instance.

**Key Responsibilities:**
1.  Read required environment variables (e.g., `AZURE_SUBSCRIPTION_ID`).
2.  Handle authentication, preferring CI/CD-friendly Service Principal credentials but falling back to `AzureCLICredential` for local development.
3.  Initialize all necessary Azure SDK clients.
4.  Return the fully configured helper struct.

**Example (`NewKubernetesClusterHelper`):**
```go
// NewKubernetesClusterHelper creates a new helper instance
func NewKubernetesClusterHelper(t *testing.T) *KubernetesClusterHelper {
	subscriptionID := getRequiredEnvVar(t, "AZURE_SUBSCRIPTION_ID")
	
	// Standard authentication logic
	credential, err := azidentity.NewDefaultAzureCredential(nil)
	require.NoError(t, err, "Failed to create default credential")

	// Initialize the required clients
	client, err := armcontainerservice.NewManagedClustersClient(subscriptionID, credential, nil)
	require.NoError(t, err, "Failed to create AKS client")

	return &KubernetesClusterHelper{
		subscriptionID: subscriptionID,
		credential:     credential,
		client:         client,
	}
}
```

## Validation Methods

Validation methods are attached to the helper struct. They contain the logic to verify that a deployed resource is configured as expected.

**Best Practices:**
-   **Single Responsibility**: Each function should validate one logical aspect (e.g., encryption, network rules, tags).
-   **Accept the SDK Object**: To minimize API calls, functions should accept the `armcontainerservice.ManagedCluster` (or similar) object, which is fetched once in the main test function.
-   **Use `require` and `assert`**: Use `require` for fatal assertions that stop the test if they fail (e.g., the resource object is `nil`). Use `assert` for non-fatal checks.
-   **Provide Clear Error Messages**: Every assertion must have a descriptive message.

### Example: Network Profile Validation
```go
// ValidateKubernetesClusterNetwork validates network profile settings
func (h *KubernetesClusterHelper) ValidateKubernetesClusterNetwork(t *testing.T, cluster armcontainerservice.ManagedCluster) {
	require.NotNil(t, cluster.Properties.NetworkProfile, "Network profile should not be nil")
	require.Equal(t, armcontainerservice.NetworkPluginAzure, *cluster.Properties.NetworkProfile.NetworkPlugin, "Network plugin should be Azure")
	require.Equal(t, armcontainerservice.NetworkPolicyAzure, *cluster.Properties.NetworkProfile.NetworkPolicy, "Network policy should be Azure")
}
```

## Waiter Functions

Azure operations can be asynchronous. Waiter functions use Terratest's `retry` package to poll a resource until it reaches a desired state.

### Example: Wait for Provisioning State
```go
// WaitForKubernetesClusterReady waits for provisioning to complete
func (h *KubernetesClusterHelper) WaitForKubernetesClusterReady(t *testing.T, resourceGroupName, clusterName string) {
	description := fmt.Sprintf("Waiting for AKS cluster %s to be ready", clusterName)
	
	// Poll for up to 10 minutes (60 attempts * 10 seconds)
	retry.DoWithRetry(t, description, 60, 10*time.Second, func() (string, error) {
		cluster := h.GetKubernetesClusterProperties(t, resourceGroupName, clusterName)
		if cluster.Properties != nil && cluster.Properties.ProvisioningState != nil && *cluster.Properties.ProvisioningState == "Succeeded" {
			return "AKS cluster is ready.", nil
		}

		return "", fmt.Errorf("AKS cluster is not ready yet")
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
			".*timeout.*":                      "Timeout error, retrying.",
			".*ResourceGroupNotFound.*":        "Resource group not found, retrying.",
			".*Another operation is in progress.*": "Another operation is in progress, retrying.",
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
