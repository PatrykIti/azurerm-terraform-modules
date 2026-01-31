package test

import (
	"context"
	"fmt"
	"os"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// TestConfig holds common test configuration
// NOTE: Keep in sync with test_env.sh and CI secrets.
type TestConfig struct {
	SubscriptionID string
	TenantID       string
	ClientID       string
	ClientSecret   string
	Location       string
	ResourceGroup  string
	UniqueID       string
}

// GetTestConfig returns a test configuration with required Azure credentials
func GetTestConfig(t *testing.T) *TestConfig {
	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	require.NotEmpty(t, subscriptionID, "ARM_SUBSCRIPTION_ID environment variable must be set")

	tenantID := os.Getenv("ARM_TENANT_ID")
	require.NotEmpty(t, tenantID, "ARM_TENANT_ID environment variable must be set")

	clientID := os.Getenv("ARM_CLIENT_ID")
	require.NotEmpty(t, clientID, "ARM_CLIENT_ID environment variable must be set")

	clientSecret := os.Getenv("ARM_CLIENT_SECRET")
	require.NotEmpty(t, clientSecret, "ARM_CLIENT_SECRET environment variable must be set")

	location := os.Getenv("ARM_LOCATION")
	if location == "" {
		location = "westeurope"
	}

	uniqueID := strings.ToLower(random.UniqueId())

	return &TestConfig{
		SubscriptionID: subscriptionID,
		TenantID:       tenantID,
		ClientID:       clientID,
		ClientSecret:   clientSecret,
		Location:       location,
		ResourceGroup:  fmt.Sprintf("rg-test-eventhub-namespace-%s", uniqueID),
		UniqueID:       uniqueID,
	}
}

// GetAzureCredential returns Azure credentials for SDK calls
func GetAzureCredential(t *testing.T) azcore.TokenCredential {
	tenantID := os.Getenv("ARM_TENANT_ID")
	clientID := os.Getenv("ARM_CLIENT_ID")
	clientSecret := os.Getenv("ARM_CLIENT_SECRET")

	if tenantID != "" && clientID != "" && clientSecret != "" {
		cred, err := azidentity.NewClientSecretCredential(tenantID, clientID, clientSecret, nil)
		require.NoError(t, err, "Failed to create service principal credential")
		return cred
	}

	cred, err := azidentity.NewDefaultAzureCredential(nil)
	require.NoError(t, err, "Failed to create default Azure credential")
	return cred
}

// WaitForResourceDeletion waits for a resource to be deleted
func WaitForResourceDeletion(ctx context.Context, checkFunc func() (bool, error), timeout time.Duration) error {
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()

	timeoutCh := time.After(timeout)

	for {
		select {
		case <-timeoutCh:
			return fmt.Errorf("timeout waiting for resource deletion")
		case <-ticker.C:
			exists, err := checkFunc()
			if err != nil {
				return fmt.Errorf("error checking resource existence: %w", err)
			}
			if !exists {
				return nil
			}
		}
	}
}

// GenerateResourceName generates a unique resource name for testing
func GenerateResourceName(prefix string, uniqueID string) string {
	name := fmt.Sprintf("%s%s", prefix, uniqueID)
	name = strings.ReplaceAll(name, "-", "")
	if len(name) > 50 {
		name = name[:50]
	}
	return strings.ToLower(name)
}

// OutputBool reads a Terraform output and parses it as a boolean.
func OutputBool(t testing.TB, terraformOptions *terraform.Options, name string) bool {
	value := terraform.Output(t, terraformOptions, name)
	parsed, err := strconv.ParseBool(strings.TrimSpace(value))
	require.NoError(t, err, "Failed to parse output %q as bool", name)
	return parsed
}
