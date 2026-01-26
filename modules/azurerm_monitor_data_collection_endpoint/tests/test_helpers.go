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
	tenantID := os.Getenv("ARM_TENANT_ID")
	clientID := os.Getenv("ARM_CLIENT_ID")
	clientSecret := os.Getenv("ARM_CLIENT_SECRET")

	require.NotEmpty(t, subscriptionID, "ARM_SUBSCRIPTION_ID environment variable must be set")
	require.NotEmpty(t, tenantID, "ARM_TENANT_ID environment variable must be set")
	require.NotEmpty(t, clientID, "ARM_CLIENT_ID environment variable must be set")
	require.NotEmpty(t, clientSecret, "ARM_CLIENT_SECRET environment variable must be set")

	location := os.Getenv("ARM_LOCATION")
	if location == "" {
		location = "northeurope"
	}

	uniqueID := strings.ToLower(random.UniqueId())

	return &TestConfig{
		SubscriptionID: subscriptionID,
		TenantID:       tenantID,
		ClientID:       clientID,
		ClientSecret:   clientSecret,
		Location:       location,
		ResourceGroup:  fmt.Sprintf("rg-test-monitor-dce-%s", uniqueID),
		UniqueID:       uniqueID,
	}
}

// GetAzureCredential returns Azure credentials for SDK calls
func GetAzureCredential(t *testing.T) azcore.TokenCredential {
	cred, err := azidentity.NewDefaultAzureCredential(nil)
	require.NoError(t, err, "Failed to create Azure credential")
	return cred
}

// WaitForResourceProvisioning waits for a resource to be provisioned
func WaitForResourceProvisioning(ctx context.Context, t *testing.T, maxWait time.Duration) context.Context {
	ctx, cancel := context.WithTimeout(ctx, maxWait)
	t.Cleanup(cancel)
	return ctx
}

// GenerateResourceName generates a unique resource name for testing
func GenerateResourceName(prefix string, uniqueID string) string {
	name := fmt.Sprintf("%s%s", prefix, uniqueID)
	name = strings.ReplaceAll(name, "-", "")
	if len(name) > 63 {
		name = name[:63]
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
