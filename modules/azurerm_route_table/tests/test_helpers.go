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
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/stretchr/testify/require"
)

// TestConfig holds common test configuration
type TestConfig struct {
	SubscriptionID    string
	TenantID         string
	ClientID         string
	ClientSecret     string
	Location         string
	ResourceGroup    string
	UniqueID         string
}

// getTerraformOptions creates a standard terraform.Options object
func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	randomSuffix := strings.ToLower(random.UniqueId())

	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"random_suffix": randomSuffix,
			"location":      "northeurope",
		},
		NoColor: true,
		RetryableTerraformErrors: map[string]string{
			".*ResourceGroupNotFound.*":      "Resource group not found, retrying.",
			".*Another operation is in progress.*": "Another operation is in progress, retrying.",
			".*timeout.*":                    "Timeout error, retrying.",
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