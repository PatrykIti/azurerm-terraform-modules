package test

import (
	"os"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func requireADOEnv(t testing.TB) {
	t.Helper()

	if os.Getenv("AZDO_ORG_SERVICE_URL") == "" || os.Getenv("AZDO_PERSONAL_ACCESS_TOKEN") == "" {
		t.Skip("Skipping Azure DevOps tests: AZDO_ORG_SERVICE_URL and AZDO_PERSONAL_ACCESS_TOKEN are required")
	}
}

func requireServicePrincipalOriginID(t testing.TB, envVar string) string {
	t.Helper()

	originID := os.Getenv(envVar)
	if originID == "" {
		t.Skipf("Skipping Azure DevOps tests: %s is required", envVar)
	}

	return originID
}

func getTerraformOptions(t testing.TB, terraformDir string, originID string) *terraform.Options {
	t.Helper()

	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"service_principal_origin_id": originID,
		},
		NoColor: true,
		RetryableTerraformErrors: map[string]string{
			".*timeout.*":         "Timeout error - retrying",
			".*TooManyRequests.*": "Too many requests - retrying",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10 * time.Second,
	}
}
