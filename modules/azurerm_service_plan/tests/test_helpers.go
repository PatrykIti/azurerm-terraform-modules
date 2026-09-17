package test

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/policy"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// TestConfig holds common test configuration.
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

// ServicePlan represents the subset of App Service Plan properties required by tests.
type ServicePlan struct {
	ID       string            `json:"id"`
	Name     string            `json:"name"`
	Kind     string            `json:"kind"`
	Location string            `json:"location"`
	Tags     map[string]string `json:"tags"`
}

// GetTestConfig returns a test configuration with required Azure credentials.
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
		ResourceGroup:  fmt.Sprintf("rg-test-service-plan-%s", uniqueID),
		UniqueID:       uniqueID,
	}
}

// GetAzureCredential returns Azure credentials for SDK calls.
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

// WaitForResourceDeletion waits for a resource to be deleted.
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

// GenerateResourceName generates a unique resource name for testing.
func GenerateResourceName(prefix string, uniqueID string) string {
	name := fmt.Sprintf("%s%s", prefix, uniqueID)
	name = strings.ReplaceAll(name, "-", "")
	if len(name) > 60 {
		name = name[:60]
	}
	return strings.ToLower(name)
}

// ServicePlanHelper provides helper methods for App Service Plan testing.
type ServicePlanHelper struct {
	subscriptionID string
	credential     azcore.TokenCredential
}

// NewServicePlanHelper creates a new helper instance.
func NewServicePlanHelper(t *testing.T) *ServicePlanHelper {
	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	require.NotEmpty(t, subscriptionID, "ARM_SUBSCRIPTION_ID environment variable must be set")

	return &ServicePlanHelper{
		subscriptionID: subscriptionID,
		credential:     GetAzureCredential(t),
	}
}

// GetServicePlan retrieves App Service Plan properties using the ARM REST API.
func (h *ServicePlanHelper) GetServicePlan(t *testing.T, resourceGroupName, servicePlanName string) ServicePlan {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer cancel()

	token, err := h.credential.GetToken(ctx, policy.TokenRequestOptions{
		Scopes: []string{"https://management.azure.com/.default"},
	})
	require.NoError(t, err, "Failed to acquire Azure management token")

	url := fmt.Sprintf(
		"https://management.azure.com/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Web/serverFarms/%s?api-version=2023-12-01",
		h.subscriptionID,
		resourceGroupName,
		servicePlanName,
	)

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	require.NoError(t, err, "Failed to create App Service Plan request")
	req.Header.Set("Authorization", "Bearer "+token.Token)

	resp, err := http.DefaultClient.Do(req)
	require.NoError(t, err, "Failed to query App Service Plan")
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	require.NoError(t, err, "Failed to read App Service Plan response")
	require.Equalf(t, http.StatusOK, resp.StatusCode, "Unexpected ARM response: %s", string(body))

	var servicePlan ServicePlan
	err = json.Unmarshal(body, &servicePlan)
	require.NoError(t, err, "Failed to decode App Service Plan response")

	return servicePlan
}

// ValidateServicePlanTags validates tags on the App Service Plan.
func ValidateServicePlanTags(t *testing.T, servicePlan ServicePlan, expectedTags map[string]string) {
	if expectedTags == nil {
		return
	}
	require.NotNil(t, servicePlan.Tags, "Service Plan tags should not be nil")

	for key, value := range expectedTags {
		actual, ok := servicePlan.Tags[key]
		require.True(t, ok, "Expected tag %s to be present", key)
		require.Equal(t, value, actual, "Tag %s should match", key)
	}
}

// OutputBool reads a Terraform output and parses it as a boolean.
func OutputBool(t testing.TB, terraformOptions *terraform.Options, name string) bool {
	value := terraform.Output(t, terraformOptions, name)
	parsed, err := strconv.ParseBool(strings.TrimSpace(value))
	require.NoError(t, err, "Failed to parse output %q as bool", name)
	return parsed
}

// OutputInt reads a Terraform output and parses it as an integer.
func OutputInt(t testing.TB, terraformOptions *terraform.Options, name string) int {
	value := terraform.Output(t, terraformOptions, name)
	parsed, err := strconv.Atoi(strings.TrimSpace(value))
	require.NoError(t, err, "Failed to parse output %q as int", name)
	return parsed
}
