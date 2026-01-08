package test

import (
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func requireADOEnv(t testing.TB, fixtureName string) {
	t.Helper()

	required := []string{
		"AZDO_ORG_SERVICE_URL",
		"AZDO_PERSONAL_ACCESS_TOKEN",
	}

	normalizedFixture := strings.ToUpper(strings.TrimSpace(fixtureName))

	var missing []string
	for _, name := range required {
		if os.Getenv(name) == "" {
			missing = append(missing, name)
		}
	}

	switch strings.ToLower(fixtureName) {
	case "basic", "secure":
		if getFixtureEnv(normalizedFixture, "AZDO_USER_PRINCIPAL_NAME") == "" {
			missing = append(missing, formatFixtureEnv("AZDO_USER_PRINCIPAL_NAME", normalizedFixture))
		}
	case "complete":
		if getFixtureEnv(normalizedFixture, "AZDO_USER_ORIGIN_ID") == "" {
			missing = append(missing, formatFixtureEnv("AZDO_USER_ORIGIN_ID", normalizedFixture))
		}
	}

	if len(missing) > 0 {
		t.Skipf("Skipping Azure DevOps tests: missing %s", strings.Join(missing, ", "))
	}
}

func getTerraformOptions(t testing.TB, terraformDir string, fixtureName string) *terraform.Options {
	t.Helper()

	normalizedFixture := strings.ToUpper(strings.TrimSpace(fixtureName))
	vars := map[string]interface{}{}

	switch strings.ToLower(fixtureName) {
	case "basic", "secure":
		principal := getFixtureEnv(normalizedFixture, "AZDO_USER_PRINCIPAL_NAME")
		if principal != "" {
			vars["user_principal_name"] = principal
		}
	case "complete":
		originID := getFixtureEnv(normalizedFixture, "AZDO_USER_ORIGIN_ID")
		if originID != "" {
			vars["user_origin_id"] = originID
		}
		userOrigin := getFixtureEnv(normalizedFixture, "AZDO_USER_ORIGIN")
		if userOrigin == "" {
			userOrigin = "aad"
		}
		vars["user_origin"] = userOrigin
	case "negative":
		principal := getFixtureEnv(normalizedFixture, "AZDO_USER_PRINCIPAL_NAME")
		if principal != "" {
			vars["user_principal_name"] = principal
		}
		originID := getFixtureEnv(normalizedFixture, "AZDO_USER_ORIGIN_ID")
		if originID != "" {
			vars["user_origin_id"] = originID
		}
		userOrigin := getFixtureEnv(normalizedFixture, "AZDO_USER_ORIGIN")
		if userOrigin != "" {
			vars["user_origin"] = userOrigin
		}
	}

	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars:         vars,
		NoColor:      true,
		RetryableTerraformErrors: map[string]string{
			".*timeout.*":         "Timeout error - retrying",
			".*TooManyRequests.*": "Too many requests - retrying",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10 * time.Second,
	}
}

func getFixtureEnv(fixtureName string, baseName string) string {
	if fixtureName != "" {
		fixtureValue := os.Getenv(fmt.Sprintf("%s_%s", baseName, fixtureName))
		if fixtureValue != "" {
			return fixtureValue
		}
	}
	return os.Getenv(baseName)
}

func formatFixtureEnv(baseName string, fixtureName string) string {
	if fixtureName == "" {
		return baseName
	}
	return fmt.Sprintf("%s or %s_%s", baseName, baseName, fixtureName)
}
