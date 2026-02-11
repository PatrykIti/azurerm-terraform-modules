package test

import (
	"fmt"
	"sync/atomic"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Test basic bastion host creation
func TestBasicBastionHost(t *testing.T) {
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

		resourceID := terraform.Output(t, terraformOptions, "bastion_host_id")
		resourceName := terraform.Output(t, terraformOptions, "bastion_host_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, resourceGroupName)
	})
}

// Test complete bastion host with features enabled
func TestCompleteBastionHost(t *testing.T) {
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

		resourceID := terraform.Output(t, terraformOptions, "bastion_host_id")
		resourceName := terraform.Output(t, terraformOptions, "bastion_host_name")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
	})
}

// Test security-focused bastion host settings
func TestSecureBastionHost(t *testing.T) {
	// Run sequentially to reduce Azure-side delete contention for Bastion in CI.

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
		resourceID := terraform.Output(t, terraformOptions, "bastion_host_id")
		assert.NotEmpty(t, resourceID)
	})
}

func TestBastionHostIPConnect(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/ip-connect")
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
		resourceID := terraform.Output(t, terraformOptions, "bastion_host_id")
		assert.NotEmpty(t, resourceID)
	})
}

func TestBastionHostTunneling(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/tunneling")
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
		resourceID := terraform.Output(t, terraformOptions, "bastion_host_id")
		assert.NotEmpty(t, resourceID)
	})
}

func TestBastionHostShareableLink(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/shareable-link")
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
		resourceID := terraform.Output(t, terraformOptions, "bastion_host_id")
		assert.NotEmpty(t, resourceID)
	})
}

func TestBastionHostFileCopy(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/file-copy")
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
		resourceID := terraform.Output(t, terraformOptions, "bastion_host_id")
		assert.NotEmpty(t, resourceID)
	})
}

func TestBastionHostDiagnosticSettings(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/diagnostic-settings")
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
		resourceID := terraform.Output(t, terraformOptions, "bastion_host_id")
		assert.NotEmpty(t, resourceID)
	})
}

// Negative test cases for validation rules
func TestBastionHostValidationRules(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name          string
		fixtureFile   string
		expectedError string
	}{
		{
			name:        "InvalidName",
			fixtureFile: "negative",
		},
	}

	for _, tc := range testCases {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", fmt.Sprintf("tests/fixtures/%s", tc.fixtureFile))
			terraformOptions := &terraform.Options{
				TerraformDir: testFolder,
				NoColor:      true,
			}

			_, err := terraform.InitAndPlanE(t, terraformOptions)
			require.Error(t, err)
			if tc.expectedError != "" {
				assert.Contains(t, err.Error(), tc.expectedError)
			}
		})
	}
}

// Benchmark test for performance
func BenchmarkBastionHostCreation(b *testing.B) {
	if testing.Short() {
		b.Skip("Skipping benchmark in short mode")
	}

	testFolder := test_structure.CopyTerraformFolderToTemp(b, "..", "tests/fixtures/basic")
	terraformOptions := getTerraformOptions(b, testFolder)

	defer terraform.Destroy(b, terraformOptions)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		terraformOptions.Vars["random_suffix"] = fmt.Sprintf("%d%s", i, terraformOptions.Vars["random_suffix"].(string)[:5])
		terraform.InitAndApply(b, terraformOptions)
		terraform.Destroy(b, terraformOptions)
	}
}

var randomSuffixCounter uint64

func generateRandomSuffix() string {
	now := uint64(time.Now().UnixNano())
	seq := atomic.AddUint64(&randomSuffixCounter, 1)
	raw := fmt.Sprintf("%x%x", now, seq)
	if len(raw) > 8 {
		return raw[len(raw)-8:]
	}

	return raw
}

func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	uniqueID := generateRandomSuffix()

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
