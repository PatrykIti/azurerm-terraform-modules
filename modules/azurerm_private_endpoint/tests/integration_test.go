package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestPrivateEndpointFullIntegration validates a complete deployment.
func TestPrivateEndpointFullIntegration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/complete")
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

		resourceID := terraform.Output(t, terraformOptions, "private_endpoint_id")
		resourceName := terraform.Output(t, terraformOptions, "private_endpoint_name")
		privateIP := terraform.Output(t, terraformOptions, "private_endpoint_private_ip")
		dnsGroup := terraform.Output(t, terraformOptions, "private_dns_zone_group")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, privateIP)
		assert.NotEmpty(t, dnsGroup)
	})
}

// TestPrivateEndpointPrivateDnsZoneGroupIntegration validates DNS zone group attachment.
func TestPrivateEndpointPrivateDnsZoneGroupIntegration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/private-dns-zone-group")
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

		resourceID := terraform.Output(t, terraformOptions, "private_endpoint_id")
		dnsGroup := terraform.Output(t, terraformOptions, "private_dns_zone_group")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, dnsGroup)
	})
}

// TestPrivateEndpointIpConfigurationIntegration validates static IP configuration.
func TestPrivateEndpointIpConfigurationIntegration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/ip-configuration")
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

		resourceID := terraform.Output(t, terraformOptions, "private_endpoint_id")
		privateIP := terraform.Output(t, terraformOptions, "private_ip_address")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, privateIP)
	})
}
