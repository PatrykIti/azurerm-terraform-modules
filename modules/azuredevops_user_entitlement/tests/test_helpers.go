package test

import (
	"os"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func requireADOEnv(t testing.TB) {
	t.Helper()

	required := []string{
		"AZDO_ORG_SERVICE_URL",
		"AZDO_PERSONAL_ACCESS_TOKEN",
		"AZDO_USER_PRINCIPAL_NAME",
		"AZDO_USER_ORIGIN_ID",
	}

	var missing []string
	for _, name := range required {
		if os.Getenv(name) == "" {
			missing = append(missing, name)
		}
	}

	if len(missing) > 0 {
		t.Skipf("Skipping Azure DevOps tests: missing %s", strings.Join(missing, ", "))
	}
}

func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	t.Helper()

	userOrigin := os.Getenv("AZDO_USER_ORIGIN")
	if userOrigin == "" {
		userOrigin = "aad"
	}

	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"user_principal_name": os.Getenv("AZDO_USER_PRINCIPAL_NAME"),
			"user_origin_id":      os.Getenv("AZDO_USER_ORIGIN_ID"),
			"user_origin":         userOrigin,
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
