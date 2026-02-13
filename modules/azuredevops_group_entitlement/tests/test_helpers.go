package test

import (
	"fmt"
	"os"
	"strings"
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

func requireADOGroupEntitlementEnv(t testing.TB, fixtureName string) {
	t.Helper()

	requireADOEnv(t)

	normalizedFixture := strings.ToUpper(strings.TrimSpace(fixtureName))
	displayName := getFixtureEnv(normalizedFixture, "AZDO_GROUP_DISPLAY_NAME")
	originID := getFixtureEnv(normalizedFixture, "AZDO_GROUP_ORIGIN_ID")

	if displayName == "" && originID == "" {
		t.Skipf(
			"Skipping Azure DevOps tests: missing %s or %s",
			formatFixtureEnv("AZDO_GROUP_DISPLAY_NAME", normalizedFixture),
			formatFixtureEnv("AZDO_GROUP_ORIGIN_ID", normalizedFixture),
		)
	}
}

func getTerraformOptions(t testing.TB, terraformDir string, fixtureName string) *terraform.Options {
	t.Helper()

	normalizedFixture := strings.ToUpper(strings.TrimSpace(fixtureName))
	vars := map[string]interface{}{}

	displayName := getFixtureEnv(normalizedFixture, "AZDO_GROUP_DISPLAY_NAME")
	originID := getFixtureEnv(normalizedFixture, "AZDO_GROUP_ORIGIN_ID")
	origin := getFixtureEnv(normalizedFixture, "AZDO_GROUP_ORIGIN")
	if origin == "" {
		origin = "aad"
	}

	switch strings.ToLower(fixtureName) {
	case "basic", "secure":
		if displayName != "" {
			vars["group_display_name"] = displayName
		}
	case "complete":
		if originID != "" {
			vars["group_origin_id"] = originID
			vars["group_origin"] = origin
		} else if displayName != "" {
			vars["group_display_name"] = displayName
		}
	case "negative":
		if displayName != "" {
			vars["group_display_name"] = displayName
		}
		if originID != "" {
			vars["group_origin_id"] = originID
		}
		vars["group_origin"] = origin
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
