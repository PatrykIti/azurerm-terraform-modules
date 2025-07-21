package test

import (
	"context"
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/containerservice/armcontainerservice/v4"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// KubernetesClusterHelper provides helper methods for AKS testing
type KubernetesClusterHelper struct {
	subscriptionID string
	credential     azcore.TokenCredential
	client         *armcontainerservice.ManagedClustersClient
}

// NewKubernetesClusterHelper creates a new helper instance for AKS
func NewKubernetesClusterHelper(t *testing.T) *KubernetesClusterHelper {
	subscriptionID := getRequiredEnvVar(t, "AZURE_SUBSCRIPTION_ID")

	credential, err := azidentity.NewDefaultAzureCredential(nil)
	require.NoError(t, err, "Failed to create default Azure credential")

	client, err := armcontainerservice.NewManagedClustersClient(subscriptionID, credential, nil)
	require.NoError(t, err, "Failed to create AKS client")

	return &KubernetesClusterHelper{
		subscriptionID: subscriptionID,
		credential:     credential,
		client:         client,
	}
}

// GetKubernetesClusterProperties retrieves the properties of an AKS cluster
func (h *KubernetesClusterHelper) GetKubernetesClusterProperties(t *testing.T, resourceGroupName, clusterName string) *armcontainerservice.ManagedCluster {
	resp, err := h.client.Get(context.Background(), resourceGroupName, clusterName, nil)
	require.NoError(t, err, "Failed to get AKS cluster properties")
	return &resp.ManagedCluster
}

// Shared test helper functions

// getTerraformOptions creates a standard terraform.Options object for tests
func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	randomSuffix := strings.ToLower(random.UniqueId())

	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"random_suffix": randomSuffix,
			"location":      "northeurope", // Standard test location
		},
		NoColor: true,
		RetryableTerraformErrors: map[string]string{
			".*timeout.*":               "Timeout error, retrying.",
			".*ResourceGroupNotFound.*": "Resource group not found, retrying.",
			".*Another operation is in progress.*": "Another operation is in progress, retrying.",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10 * time.Second,
	}
}

// getRequiredEnvVar gets a required environment variable or fails the test
func getRequiredEnvVar(t *testing.T, envVarName string) string {
	value := os.Getenv(envVarName)
	require.NotEmpty(t, value, fmt.Sprintf("Required environment variable '%s' is not set.", envVarName))
	return value
}
