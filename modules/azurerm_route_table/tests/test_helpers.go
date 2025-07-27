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
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/network/armnetwork/v4"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// RouteTableHelper provides helper methods for Route Table testing
type RouteTableHelper struct {
	subscriptionID string
	credential     azcore.TokenCredential
	client         *armnetwork.RouteTablesClient
	routesClient   *armnetwork.RoutesClient
}

// NewRouteTableHelper creates a new helper instance for Route Tables
func NewRouteTableHelper(t *testing.T) *RouteTableHelper {
	subscriptionID := getRequiredEnvVar(t, "AZURE_SUBSCRIPTION_ID")

	credential, err := azidentity.NewDefaultAzureCredential(nil)
	require.NoError(t, err, "Failed to create default Azure credential")

	client, err := armnetwork.NewRouteTablesClient(subscriptionID, credential, nil)
	require.NoError(t, err, "Failed to create Route Tables client")

	routesClient, err := armnetwork.NewRoutesClient(subscriptionID, credential, nil)
	require.NoError(t, err, "Failed to create Routes client")

	return &RouteTableHelper{
		subscriptionID: subscriptionID,
		credential:     credential,
		client:         client,
		routesClient:   routesClient,
	}
}

// GetRouteTableProperties retrieves the properties of a Route Table
func (h *RouteTableHelper) GetRouteTableProperties(t *testing.T, resourceGroupName, routeTableName string) *armnetwork.RouteTable {
	resp, err := h.client.Get(context.Background(), resourceGroupName, routeTableName, nil)
	require.NoError(t, err, "Failed to get Route Table properties")
	return &resp.RouteTable
}

// GetRoutes retrieves all routes in a Route Table
func (h *RouteTableHelper) GetRoutes(t *testing.T, resourceGroupName, routeTableName string) []*armnetwork.Route {
	pager := h.routesClient.NewListPager(resourceGroupName, routeTableName, nil)
	var routes []*armnetwork.Route
	
	for pager.More() {
		page, err := pager.NextPage(context.Background())
		require.NoError(t, err, "Failed to get routes page")
		routes = append(routes, page.Value...)
	}
	
	return routes
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