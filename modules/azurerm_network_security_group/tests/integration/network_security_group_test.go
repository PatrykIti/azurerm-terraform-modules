package test

import (
	"testing"
	"fmt"
	"strings"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestNetworkSecurityGroupBasic tests basic NSG creation
func TestNetworkSecurityGroupBasic(t *testing.T) {
	t.Parallel()

	// Generate a random ID to namespace resources
	uniqueID := random.UniqueId()
	resourceGroupName := fmt.Sprintf("rg-test-nsg-%s", uniqueID)
	nsgName := fmt.Sprintf("nsg-test-%s", uniqueID)
	location := "eastus"

	// Configure Terraform
	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",
		Vars: map[string]interface{}{
			"resource_group_name": resourceGroupName,
			"location":           location,
			"name_suffix":        uniqueID,
		},
		RetryableTerraformErrors: map[string]string{
			".*": "Retryable error",
		},
		MaxRetries: 3,
	}

	defer terraform.Destroy(t, terraformOptions)

	// Run terraform init and apply
	terraform.InitAndApply(t, terraformOptions)

	// Verify the NSG exists
	actualNSGName := terraform.Output(t, terraformOptions, "network_security_group_name")
	assert.Contains(t, actualNSGName, uniqueID)

	// Verify the NSG exists in Azure
	nsgExists := azure.NetworkSecurityGroupExists(t, resourceGroupName, actualNSGName, "")
	assert.True(t, nsgExists, "Network Security Group should exist")

	// Get NSG details
	nsg := azure.GetNetworkSecurityGroup(t, resourceGroupName, actualNSGName, "")
	
	// Verify basic properties
	assert.Equal(t, location, *nsg.Location)
	assert.NotNil(t, nsg.SecurityRules)
	
	// Verify security rules
	securityRuleIDs := terraform.OutputMap(t, terraformOptions, "security_rule_ids")
	assert.Greater(t, len(securityRuleIDs), 0, "Should have at least one security rule")
}

// TestNetworkSecurityGroupComplete tests NSG with all features
func TestNetworkSecurityGroupComplete(t *testing.T) {
	t.Parallel()

	// Generate a random ID to namespace resources
	uniqueID := random.UniqueId()
	resourceGroupName := fmt.Sprintf("rg-test-nsg-complete-%s", uniqueID)
	location := "eastus"

	// Configure Terraform
	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/complete",
		Vars: map[string]interface{}{
			"resource_group_name": resourceGroupName,
			"location":           location,
			"name_suffix":        uniqueID,
		},
		RetryableTerraformErrors: map[string]string{
			".*": "Retryable error",
		},
		MaxRetries: 3,
	}

	defer terraform.Destroy(t, terraformOptions)

	// Run terraform init and apply
	terraform.InitAndApply(t, terraformOptions)

	// Verify outputs
	nsgName := terraform.Output(t, terraformOptions, "network_security_group_name")
	nsgID := terraform.Output(t, terraformOptions, "network_security_group_id")
	flowLogEnabled := terraform.Output(t, terraformOptions, "flow_log_enabled")
	trafficAnalyticsEnabled := terraform.Output(t, terraformOptions, "traffic_analytics_enabled")

	// Assertions
	assert.Contains(t, nsgName, uniqueID)
	assert.Contains(t, nsgID, "Microsoft.Network/networkSecurityGroups")
	assert.Equal(t, "true", flowLogEnabled, "Flow logs should be enabled")
	assert.Equal(t, "true", trafficAnalyticsEnabled, "Traffic analytics should be enabled")

	// Verify NSG exists
	nsgExists := azure.NetworkSecurityGroupExists(t, resourceGroupName, nsgName, "")
	assert.True(t, nsgExists, "Network Security Group should exist")

	// Get NSG details
	nsg := azure.GetNetworkSecurityGroup(t, resourceGroupName, nsgName, "")
	
	// Verify location and tags
	assert.Equal(t, location, *nsg.Location)
	assert.NotNil(t, nsg.Tags)
	
	// Verify security rules
	securityRuleIDs := terraform.OutputMap(t, terraformOptions, "security_rule_ids")
	assert.Greater(t, len(securityRuleIDs), 5, "Should have multiple security rules")

	// Verify flow log ID is present
	flowLogID := terraform.Output(t, terraformOptions, "flow_log_id")
	assert.NotEmpty(t, flowLogID, "Flow log ID should be present")
}

// TestNetworkSecurityGroupSecurityRules tests various security rule configurations
func TestNetworkSecurityGroupSecurityRules(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name                    string
		securityRules          map[string]interface{}
		expectedRuleCount      int
		expectedPriorities     []int
		expectedDirections     []string
	}{
		{
			name: "SingleInboundRule",
			securityRules: map[string]interface{}{
				"allow_ssh": map[string]interface{}{
					"priority":                   100,
					"direction":                  "Inbound",
					"access":                     "Allow",
					"protocol":                   "Tcp",
					"source_port_range":          "*",
					"destination_port_range":     "22",
					"source_address_prefix":      "10.0.0.0/8",
					"destination_address_prefix": "*",
				},
			},
			expectedRuleCount:  1,
			expectedPriorities: []int{100},
			expectedDirections: []string{"Inbound"},
		},
		{
			name: "MultipleRulesWithServiceTags",
			securityRules: map[string]interface{}{
				"allow_http": map[string]interface{}{
					"priority":                   100,
					"direction":                  "Inbound",
					"access":                     "Allow",
					"protocol":                   "Tcp",
					"source_port_range":          "*",
					"destination_port_range":     "80",
					"source_address_prefix":      "Internet",
					"destination_address_prefix": "VirtualNetwork",
				},
				"allow_https": map[string]interface{}{
					"priority":                   110,
					"direction":                  "Inbound",
					"access":                     "Allow",
					"protocol":                   "Tcp",
					"source_port_range":          "*",
					"destination_port_range":     "443",
					"source_address_prefix":      "Internet",
					"destination_address_prefix": "VirtualNetwork",
				},
				"deny_all": map[string]interface{}{
					"priority":                   4096,
					"direction":                  "Inbound",
					"access":                     "Deny",
					"protocol":                   "*",
					"source_port_range":          "*",
					"destination_port_range":     "*",
					"source_address_prefix":      "*",
					"destination_address_prefix": "*",
				},
			},
			expectedRuleCount:  3,
			expectedPriorities: []int{100, 110, 4096},
			expectedDirections: []string{"Inbound", "Inbound", "Inbound"},
		},
	}

	for _, tc := range testCases {
		tc := tc // Capture range variable
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			// Generate unique resources for this test
			uniqueID := random.UniqueId()
			resourceGroupName := fmt.Sprintf("rg-test-nsg-%s-%s", strings.ToLower(tc.name), uniqueID)
			nsgName := fmt.Sprintf("nsg-test-%s", uniqueID)
			location := "eastus"

			// Configure Terraform
			terraformOptions := &terraform.Options{
				TerraformDir: "../../",
				Vars: map[string]interface{}{
					"name":                resourceGroupName,
					"resource_group_name": resourceGroupName,
					"location":           location,
					"security_rules":     tc.securityRules,
				},
			}

			defer terraform.Destroy(t, terraformOptions)

			// Create resource group first
			azure.CreateResourceGroup(t, resourceGroupName, location)
			defer azure.DeleteResourceGroup(t, resourceGroupName)

			// Run terraform init and apply
			terraform.InitAndApply(t, terraformOptions)

			// Verify outputs
			securityRuleIDs := terraform.OutputMap(t, terraformOptions, "security_rule_ids")
			assert.Equal(t, tc.expectedRuleCount, len(securityRuleIDs), "Should have expected number of rules")
		})
	}
}

// TestNetworkSecurityGroupValidation tests input validation
func TestNetworkSecurityGroupValidation(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name          string
		vars          map[string]interface{}
		expectError   bool
		errorContains string
	}{
		{
			name: "InvalidPriority",
			vars: map[string]interface{}{
				"security_rules": map[string]interface{}{
					"invalid_rule": map[string]interface{}{
						"priority":                   5000, // Above 4096
						"direction":                  "Inbound",
						"access":                     "Allow",
						"protocol":                   "Tcp",
						"source_port_range":          "*",
						"destination_port_range":     "22",
						"source_address_prefix":      "*",
						"destination_address_prefix": "*",
					},
				},
			},
			expectError:   true,
			errorContains: "Priority must be between 100 and 4096",
		},
		{
			name: "InvalidDirection",
			vars: map[string]interface{}{
				"security_rules": map[string]interface{}{
					"invalid_rule": map[string]interface{}{
						"priority":                   100,
						"direction":                  "Bidirectional", // Invalid
						"access":                     "Allow",
						"protocol":                   "Tcp",
						"source_port_range":          "*",
						"destination_port_range":     "22",
						"source_address_prefix":      "*",
						"destination_address_prefix": "*",
					},
				},
			},
			expectError:   true,
			errorContains: "Direction must be either 'Inbound' or 'Outbound'",
		},
	}

	for _, tc := range testCases {
		tc := tc // Capture range variable
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			uniqueID := random.UniqueId()
			resourceGroupName := fmt.Sprintf("rg-test-%s", uniqueID)

			// Base configuration
			baseVars := map[string]interface{}{
				"name":                resourceGroupName,
				"resource_group_name": resourceGroupName,
				"location":           "eastus",
			}

			// Merge with test case vars
			for k, v := range tc.vars {
				baseVars[k] = v
			}

			terraformOptions := &terraform.Options{
				TerraformDir: "../../",
				Vars:         baseVars,
			}

			if tc.expectError {
				// Expect plan to fail
				_, err := terraform.InitAndPlanE(t, terraformOptions)
				require.Error(t, err)
				assert.Contains(t, err.Error(), tc.errorContains)
			} else {
				// Should succeed
				terraform.InitAndPlan(t, terraformOptions)
			}
		})
	}
}