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
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/postgresql/armpostgresqlflexibleservers/v4"
	"github.com/gruntwork-io/terratest/modules/random"
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
		ResourceGroup:  fmt.Sprintf("rg-test-postgresql-flexible-server-%s", uniqueID),
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
	if len(name) > 63 {
		name = name[:63]
	}
	return strings.ToLower(name)
}

// PostgresqlFlexibleServerHelper provides helper methods for PostgreSQL Flexible Server testing
// NOTE: Uses the new Azure SDK to query server state.
type PostgresqlFlexibleServerHelper struct {
	subscriptionID string
	credential     azcore.TokenCredential
	serversClient  *armpostgresqlflexibleservers.ServersClient
}

// NewPostgresqlFlexibleServerHelper creates a new helper instance
func NewPostgresqlFlexibleServerHelper(t *testing.T) *PostgresqlFlexibleServerHelper {
	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	require.NotEmpty(t, subscriptionID, "ARM_SUBSCRIPTION_ID environment variable must be set")

	credential := GetAzureCredential(t)

	serversClient, err := armpostgresqlflexibleservers.NewServersClient(subscriptionID, credential, nil)
	require.NoError(t, err, "Failed to create PostgreSQL Flexible Servers client")

	return &PostgresqlFlexibleServerHelper{
		subscriptionID: subscriptionID,
		credential:     credential,
		serversClient:  serversClient,
	}
}

// GetServer retrieves PostgreSQL Flexible Server properties
func (h *PostgresqlFlexibleServerHelper) GetServer(t *testing.T, resourceGroupName, serverName string) armpostgresqlflexibleservers.Server {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer cancel()

	resp, err := h.serversClient.Get(ctx, resourceGroupName, serverName, nil)
	require.NoError(t, err, "Failed to get PostgreSQL Flexible Server properties")

	return resp.Server
}

// ValidateServerTags validates tags on the server
func ValidateServerTags(t *testing.T, server armpostgresqlflexibleservers.Server, expectedTags map[string]string) {
	if expectedTags == nil {
		return
	}
	require.NotNil(t, server.Tags, "Server tags should not be nil")

	for key, value := range expectedTags {
		actual, ok := server.Tags[key]
		require.True(t, ok, "Expected tag %s to be present", key)
		require.NotNil(t, actual, "Tag %s should not be nil", key)
		require.Equal(t, value, *actual, "Tag %s should match", key)
	}
}
