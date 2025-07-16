package test

import (
	"context"
	"fmt"
	"os"
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// TestConfig holds common test configuration
type TestConfig struct {
	SubscriptionID string
	TenantID       string
	ClientID       string
	ClientSecret   string
	Location       string
}

// GetTestConfig retrieves test configuration from environment variables
func GetTestConfig(t *testing.T) *TestConfig {
	return &TestConfig{
		SubscriptionID: getRequiredEnvVar(t, "ARM_SUBSCRIPTION_ID"),
		TenantID:       getRequiredEnvVar(t, "ARM_TENANT_ID"),
		ClientID:       getRequiredEnvVar(t, "ARM_CLIENT_ID"),
		ClientSecret:   getRequiredEnvVar(t, "ARM_CLIENT_SECRET"),
		Location:       getEnvVarWithDefault("ARM_TEST_LOCATION", "northeurope"),
	}
}

// getEnvVarWithDefault gets an environment variable with a default value
func getEnvVarWithDefault(name, defaultValue string) string {
	if value := os.Getenv(name); value != "" {
		return value
	}
	return defaultValue
}

// GetAzureCredential creates an Azure credential for authentication
func GetAzureCredential(t *testing.T) *azidentity.DefaultAzureCredential {
	cred, err := azidentity.NewDefaultAzureCredential(nil)
	require.NoError(t, err, "Failed to create Azure credential")
	return cred
}

// getTerraformOptions creates common Terraform options with Azure backend
func getTerraformOptions(t *testing.T, terraformDir string, vars map[string]interface{}) *terraform.Options {
	// Add common variables
	if vars == nil {
		vars = make(map[string]interface{})
	}

	// Add location if not specified
	if _, exists := vars["location"]; !exists {
		vars["location"] = getEnvVarWithDefault("ARM_TEST_LOCATION", "northeurope")
	}

	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars:         vars,
		NoColor:      true,
		BackendConfig: map[string]interface{}{
			"resource_group_name":  getEnvVarWithDefault("TF_BACKEND_RESOURCE_GROUP", ""),
			"storage_account_name": getEnvVarWithDefault("TF_BACKEND_STORAGE_ACCOUNT", ""),
			"container_name":       getEnvVarWithDefault("TF_BACKEND_CONTAINER", ""),
			"key":                  fmt.Sprintf("subnet-test-%s.tfstate", terraformDir),
		},
	}
}

// ValidateSubnetName validates the subnet name format
func ValidateSubnetName(t *testing.T, name string) {
	require.NotEmpty(t, name, "Subnet name should not be empty")
	require.LessOrEqual(t, len(name), 80, "Subnet name should not exceed 80 characters")
	// Add more validation as needed based on Azure requirements
}

// GetContext returns a context for Azure operations
func GetContext() context.Context {
	return context.Background()
}