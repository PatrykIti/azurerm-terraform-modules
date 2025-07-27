package test

import (
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/network/armnetwork/v4"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Test basic Route Table creation
func TestBasicRouteTable(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../fixtures", "basic")

	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		helper := NewRouteTableHelper(t)

		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		routeTableName := terraform.Output(t, terraformOptions, "route_table_name")

		routeTable := helper.GetRouteTableProperties(t, resourceGroupName, routeTableName)

		assert.Equal(t, "Succeeded", string(*routeTable.Properties.ProvisioningState))
		assert.True(t, *routeTable.Properties.DisableBgpRoutePropagation == false)
		assert.Equal(t, 0, len(routeTable.Properties.Routes))
	})
}

// Test a more complete Route Table configuration
func TestCompleteRouteTable(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../fixtures", "complete")

	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		helper := NewRouteTableHelper(t)

		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		routeTableName := terraform.Output(t, terraformOptions, "route_table_name")

		routeTable := helper.GetRouteTableProperties(t, resourceGroupName, routeTableName)

		assert.Equal(t, "Succeeded", string(*routeTable.Properties.ProvisioningState))
		assert.True(t, *routeTable.Properties.DisableBgpRoutePropagation)
		assert.True(t, len(routeTable.Properties.Routes) > 0)
		
		// Validate routes
		routes := helper.GetRoutes(t, resourceGroupName, routeTableName)
		assert.Greater(t, len(routes), 0)
		
		for _, route := range routes {
			assert.NotNil(t, route.Properties.AddressPrefix)
			assert.NotNil(t, route.Properties.NextHopType)
		}
	})
}

// Test a security-hardened Route Table
func TestSecureRouteTable(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../fixtures", "secure")

	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		helper := NewRouteTableHelper(t)

		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		routeTableName := terraform.Output(t, terraformOptions, "route_table_name")

		routeTable := helper.GetRouteTableProperties(t, resourceGroupName, routeTableName)

		// Validate security configuration - BGP should be disabled for secure scenarios
		assert.True(t, *routeTable.Properties.DisableBgpRoutePropagation)
		
		// Validate routes point to firewall/NVA
		routes := helper.GetRoutes(t, resourceGroupName, routeTableName)
		for _, route := range routes {
			if *route.Properties.AddressPrefix == "0.0.0.0/0" {
				assert.Equal(t, armnetwork.RouteNextHopTypeVirtualAppliance, *route.Properties.NextHopType)
				assert.NotNil(t, route.Properties.NextHopIPAddress)
			}
		}
	})
}

// Test Route Table with advanced network configuration
func TestNetworkRouteTable(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../fixtures", "network")

	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		helper := NewRouteTableHelper(t)

		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		routeTableName := terraform.Output(t, terraformOptions, "route_table_name")

		routeTable := helper.GetRouteTableProperties(t, resourceGroupName, routeTableName)

		// Validate network configuration
		assert.Equal(t, "Succeeded", string(*routeTable.Properties.ProvisioningState))
		
		// Validate multiple routes for hub-spoke or complex scenarios
		routes := helper.GetRoutes(t, resourceGroupName, routeTableName)
		assert.GreaterOrEqual(t, len(routes), 2, "Should have at least 2 routes for network scenario")
		
		// Check for specific route types
		hasInternetRoute := false
		hasVirtualApplianceRoute := false
		for _, route := range routes {
			if *route.Properties.NextHopType == armnetwork.RouteNextHopTypeInternet {
				hasInternetRoute = true
			}
			if *route.Properties.NextHopType == armnetwork.RouteNextHopTypeVirtualAppliance {
				hasVirtualApplianceRoute = true
			}
		}
		assert.True(t, hasInternetRoute || hasVirtualApplianceRoute, "Should have either Internet or Virtual Appliance routes")
	})
}

// Negative test cases for validation rules
func TestRouteTableValidationRules(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name          string
		vars          map[string]interface{}
		expectedError string
	}{
		{
			name: "InvalidName",
			vars: map[string]interface{}{
				"route_table_name": "RT-Invalid-Name-With-Special-Characters-That-Is-Way-Too-Long-And-Should-Definitely-Fail-Validation",
			},
			expectedError: "Route Table name must be 1-80 characters long",
		},
		{
			name: "InvalidRouteNextHop",
			vars: map[string]interface{}{
				"routes": []map[string]interface{}{
					{
						"name":           "invalid-route",
						"address_prefix": "10.0.0.0/16",
						"next_hop_type":  "InvalidType",
					},
				},
			},
			expectedError: "next_hop_type must be one of",
		},
		{
			name: "MissingNextHopIP",
			vars: map[string]interface{}{
				"routes": []map[string]interface{}{
					{
						"name":                   "missing-ip",
						"address_prefix":         "10.0.0.0/16",
						"next_hop_type":          "VirtualAppliance",
						"next_hop_in_ip_address": "",
					},
				},
			},
			expectedError: "next_hop_in_ip_address must be provided when next_hop_type is 'VirtualAppliance'",
		},
	}

	for _, tc := range testCases {
		tc := tc // capture range variable
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			testFolder := test_structure.CopyTerraformFolderToTemp(t, "../fixtures", "negative")
			
			// Merge the random_suffix with the test case variables
			vars := getTerraformOptions(t, testFolder).Vars
			for k, v := range tc.vars {
				vars[k] = v
			}

			terraformOptions := &terraform.Options{
				TerraformDir: testFolder,
				Vars:         vars,
				NoColor:      true,
			}

			_, err := terraform.InitAndPlanE(t, terraformOptions)
			require.Error(t, err)
			assert.Contains(t, err.Error(), tc.expectedError)
		})
	}
}
