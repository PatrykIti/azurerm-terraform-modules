package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestRouteTableLifecycle tests the update and idempotency of the Route Table module
func TestRouteTableLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping lifecycle test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_route_table/tests/fixtures/basic")

	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	// Deploy initial version
	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	// Validate initial deployment and then update
	test_structure.RunTestStage(t, "validate_and_update", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		helper := NewRouteTableHelper(t)

		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		routeTableName := terraform.Output(t, terraformOptions, "route_table_name")

		// Validate initial state - should have no routes
		routeTable := helper.GetRouteTableProperties(t, resourceGroupName, routeTableName)
		assert.Equal(t, 0, len(routeTable.Properties.Routes))

		// Update with new routes
		terraformOptions.Vars["routes"] = []map[string]interface{}{
			{
				"name":           "new-route",
				"address_prefix": "10.0.0.0/16",
				"next_hop_type":  "Internet",
			},
		}
		terraform.Apply(t, terraformOptions)

		// Validate the updated route table
		routeTableAfterUpdate := helper.GetRouteTableProperties(t, resourceGroupName, routeTableName)
		routes := helper.GetRoutes(t, resourceGroupName, routeTableName)
		assert.Equal(t, 1, len(routes))
		assert.Equal(t, "new-route", *routes[0].Name)

		// Run apply again to check for idempotency
		terraform.Apply(t, terraformOptions)
	})
}

// TestRouteTableMultipleUpdates tests multiple consecutive updates
func TestRouteTableMultipleUpdates(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping multiple updates test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_route_table/tests/fixtures/complete")

	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	// Deploy initial version
	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	// Perform multiple updates
	test_structure.RunTestStage(t, "multiple_updates", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		helper := NewRouteTableHelper(t)

		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		routeTableName := terraform.Output(t, terraformOptions, "route_table_name")

		// First update: Change BGP propagation
		terraformOptions.Vars["bgp_route_propagation_enabled"] = false
		terraform.Apply(t, terraformOptions)

		routeTable1 := helper.GetRouteTableProperties(t, resourceGroupName, routeTableName)
		assert.True(t, *routeTable1.Properties.DisableBgpRoutePropagation)

		// Second update: Add more routes
		terraformOptions.Vars["additional_routes"] = []map[string]interface{}{
			{
				"name":           "extra-route",
				"address_prefix": "192.168.0.0/16",
				"next_hop_type":  "VnetLocal",
			},
		}
		terraform.Apply(t, terraformOptions)

		routes2 := helper.GetRoutes(t, resourceGroupName, routeTableName)
		foundExtraRoute := false
		for _, route := range routes2 {
			if *route.Name == "extra-route" {
				foundExtraRoute = true
				break
			}
		}
		assert.True(t, foundExtraRoute, "Extra route should exist after update")

		// Third update: Change tags
		terraformOptions.Vars["tags"] = map[string]string{
			"Environment": "Test-Updated",
			"Managed":     "Terratest",
		}
		terraform.Apply(t, terraformOptions)

		routeTable3 := helper.GetRouteTableProperties(t, resourceGroupName, routeTableName)
		assert.Equal(t, "Test-Updated", routeTable3.Tags["Environment"])
		assert.Equal(t, "Terratest", routeTable3.Tags["Managed"])
	})
}

// TestRouteTableWithSubnetAssociation tests route table with subnet associations
func TestRouteTableWithSubnetAssociation(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping subnet association test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_route_table/tests/fixtures/network")

	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	// Deploy with subnet associations
	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	// Validate subnet associations
	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		
		// Check that subnet associations were created
		subnetCount := terraform.OutputList(t, terraformOptions, "associated_subnet_ids")
		assert.Greater(t, len(subnetCount), 0, "Should have at least one subnet associated")
		
		// Verify route table is properly configured
		helper := NewRouteTableHelper(t)
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		routeTableName := terraform.Output(t, terraformOptions, "route_table_name")
		
		routeTable := helper.GetRouteTableProperties(t, resourceGroupName, routeTableName)
		assert.NotNil(t, routeTable.Properties.Subnets)
		assert.Greater(t, len(routeTable.Properties.Subnets), 0, "Route table should have associated subnets")
	})
}