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

	missing := []string{}

	required := []string{
		"AZDO_ORG_SERVICE_URL",
		"AZDO_PERSONAL_ACCESS_TOKEN",
		"AZDO_PROJECT_ID",
		"AZDO_SECURITYROLE_ASSIGNMENT_IDENTITY_ID_BASIC",
		"AZDO_SECURITYROLE_ASSIGNMENT_IDENTITY_ID_COMPLETE",
		"AZDO_SECURITYROLE_ASSIGNMENT_IDENTITY_ID_SECURE",
	}

	for _, key := range required {
		if os.Getenv(key) == "" {
			missing = append(missing, key)
		}
	}

	if len(missing) > 0 {
		t.Skipf("Skipping Azure DevOps tests: missing %s", strings.Join(missing, ", "))
	}
}

func getProjectID(t testing.TB) string {
	t.Helper()

	return os.Getenv("AZDO_PROJECT_ID")
}

func getScopeIDBasic(t testing.TB) string {
	t.Helper()

	if scopeID := os.Getenv("AZDO_SECURITYROLE_ASSIGNMENT_SCOPE_ID_BASIC"); scopeID != "" {
		return scopeID
	}

	return getProjectID(t)
}

func getScopeIDComplete(t testing.TB) string {
	t.Helper()

	if scopeID := os.Getenv("AZDO_SECURITYROLE_ASSIGNMENT_SCOPE_ID_COMPLETE"); scopeID != "" {
		return scopeID
	}

	return getProjectID(t)
}

func getScopeIDSecure(t testing.TB) string {
	t.Helper()

	if scopeID := os.Getenv("AZDO_SECURITYROLE_ASSIGNMENT_SCOPE_ID_SECURE"); scopeID != "" {
		return scopeID
	}

	return getProjectID(t)
}

func getResourceIDBasic(t testing.TB) string {
	t.Helper()

	if resourceID := os.Getenv("AZDO_SECURITYROLE_ASSIGNMENT_RESOURCE_ID_BASIC"); resourceID != "" {
		return resourceID
	}

	return getProjectID(t)
}

func getResourceIDComplete(t testing.TB) string {
	t.Helper()

	if resourceID := os.Getenv("AZDO_SECURITYROLE_ASSIGNMENT_RESOURCE_ID_COMPLETE"); resourceID != "" {
		return resourceID
	}

	return getProjectID(t)
}

func getResourceIDSecure(t testing.TB) string {
	t.Helper()

	if resourceID := os.Getenv("AZDO_SECURITYROLE_ASSIGNMENT_RESOURCE_ID_SECURE"); resourceID != "" {
		return resourceID
	}

	return getProjectID(t)
}

func getIdentityIDBasic(t testing.TB) string {
	t.Helper()

	return os.Getenv("AZDO_SECURITYROLE_ASSIGNMENT_IDENTITY_ID_BASIC")
}

func getIdentityIDComplete(t testing.TB) string {
	t.Helper()

	return os.Getenv("AZDO_SECURITYROLE_ASSIGNMENT_IDENTITY_ID_COMPLETE")
}

func getIdentityIDSecure(t testing.TB) string {
	t.Helper()

	return os.Getenv("AZDO_SECURITYROLE_ASSIGNMENT_IDENTITY_ID_SECURE")
}

func getTerraformOptions(t testing.TB, terraformDir string, scopeID string, resourceID string, identityID string) *terraform.Options {
	t.Helper()

	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"resource_id": resourceID,
			"scope":       scopeID,
			"identity_id": identityID,
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
