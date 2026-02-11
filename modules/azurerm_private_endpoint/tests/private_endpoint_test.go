package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestBasicPrivateEndpoint(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder))
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
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		privateIP := terraform.Output(t, terraformOptions, "private_endpoint_private_ip")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, resourceGroupName)
		assert.NotEmpty(t, privateIP)
	})
}

func TestCompletePrivateEndpoint(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/complete")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder))
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

func TestSecurePrivateEndpoint(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/secure")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder))
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

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, privateIP)
	})
}

func TestPrivateEndpointIpConfiguration(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/ip-configuration")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder))
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

func TestPrivateEndpointPrivateDnsZoneGroup(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/private-dns-zone-group")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder))
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

func TestPrivateEndpointValidationRules(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/negative")
	terraformOptions := &terraform.Options{
		TerraformDir: testFolder,
		NoColor:      true,
	}

	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
}

// Helper function to get terraform options
func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	timestamp := time.Now().UnixNano() % 1000
	baseID := strings.ToLower(random.UniqueId())
	uniqueID := fmt.Sprintf("%s%03d", baseID[:5], timestamp)

	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"random_suffix": uniqueID,
			"location":      "northeurope",
		},
		NoColor: true,
		RetryableTerraformErrors: map[string]string{
			".*timeout.*":               "Timeout error - retrying",
			".*ResourceGroupNotFound.*": "Resource group not found - retrying",
			".*AlreadyExists.*":         "Resource already exists - retrying",
			".*TooManyRequests.*":       "Too many requests - retrying",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10 * time.Second,
	}
}
