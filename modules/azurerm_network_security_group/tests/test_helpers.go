package test

import (
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/network/armnetwork"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// NetworkSecurityGroupHelper provides helper methods for network security group testing
type NetworkSecurityGroupHelper struct {
	subscriptionID string
	credential     azcore.TokenCredential
	nsgClient      *armnetwork.SecurityGroupsClient
	rulesClient    *armnetwork.SecurityRulesClient
}

// NewNetworkSecurityGroupHelper creates a new helper instance
func NewNetworkSecurityGroupHelper(t *testing.T) *NetworkSecurityGroupHelper {
	subscriptionID := getRequiredEnvVar(t, "AZURE_SUBSCRIPTION_ID")

	credential, err := azidentity.NewDefaultAzureCredential(nil)
	require.NoError(t, err, "Failed to create default credential")

	nsgClient, err := armnetwork.NewSecurityGroupsClient(subscriptionID, credential, nil)
	require.NoError(t, err, "Failed to create network security groups client")

	rulesClient, err := armnetwork.NewSecurityRulesClient(subscriptionID, credential, nil)
	require.NoError(t, err, "Failed to create security rules client")

	return &NetworkSecurityGroupHelper{
		subscriptionID: subscriptionID,
		credential:     credential,
		nsgClient:      nsgClient,
		rulesClient:    rulesClient,
	}
}

// GetNsgProperties fetches the properties of a Network Security Group
func (h *NetworkSecurityGroupHelper) GetNsgProperties(t *testing.T, resourceGroupName, nsgName string) *armnetwork.SecurityGroup {
	resp, err := h.nsgClient.Get(context.Background(), resourceGroupName, nsgName, nil)
	require.NoError(t, err, "Failed to get Network Security Group properties")
	return &resp.SecurityGroup
}

// ValidateNsgSecurityRules validates the security rules of a Network Security Group
func (h *NetworkSecurityGroupHelper) ValidateNsgSecurityRules(t *testing.T, nsg *armnetwork.SecurityGroup, expectedRuleCount int) {
	require.NotNil(t, nsg.Properties, "NSG properties should not be nil")
	require.NotNil(t, nsg.Properties.SecurityRules, "Security rules should not be nil")
	require.Len(t, nsg.Properties.SecurityRules, expectedRuleCount, "Incorrect number of security rules")
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
