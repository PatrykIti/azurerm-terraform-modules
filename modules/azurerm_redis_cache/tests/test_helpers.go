package test

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
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
		location = "West Europe"
	}

	uniqueID := strings.ToLower(random.UniqueId())

	return &TestConfig{
		SubscriptionID: subscriptionID,
		TenantID:       tenantID,
		ClientID:       clientID,
		ClientSecret:   clientSecret,
		Location:       location,
		ResourceGroup:  fmt.Sprintf("rg-test-redis_cache-%s", uniqueID),
		UniqueID:       uniqueID,
	}
}

// GetAzureCredential returns Azure credentials for SDK calls
func GetAzureCredential(t *testing.T) azcore.TokenCredential {
	cred, err := azidentity.NewDefaultAzureCredential(nil)
	require.NoError(t, err, "Failed to create Azure credential")
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
	// Ensure the name meets Azure naming requirements
	name := fmt.Sprintf("%s%s", prefix, uniqueID)
	// Remove any invalid characters and ensure length limits
	name = strings.ReplaceAll(name, "-", "")
	if len(name) > 24 {
		name = name[:24]
	}
	return strings.ToLower(name)
}

// PrepareTerraformWorkingDirs removes local Terraform artifacts from copied fixtures.
// This prevents stale module snapshots in .terraform from previous runs.
func PrepareTerraformWorkingDirs(t testing.TB, terraformDir string) {
	t.Helper()

	moduleRoot := filepath.Clean(filepath.Join(terraformDir, "../../.."))

	pathsToClean := []string{
		filepath.Join(terraformDir, ".terraform"),
		filepath.Join(terraformDir, ".terraform.lock.hcl"),
		filepath.Join(terraformDir, "terraform.tfstate"),
		filepath.Join(terraformDir, "terraform.tfstate.backup"),
		filepath.Join(terraformDir, "crash.log"),
		filepath.Join(moduleRoot, ".terraform"),
		filepath.Join(moduleRoot, ".terraform.lock.hcl"),
	}

	for _, path := range pathsToClean {
		if err := os.RemoveAll(path); err != nil {
			t.Fatalf("failed to clean terraform artifact %s: %v", path, err)
		}
	}
}
