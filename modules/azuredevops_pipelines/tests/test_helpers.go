package test

import (
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

func requireADOEnv(t testing.TB) {
	t.Helper()

	if os.Getenv("AZDO_ORG_SERVICE_URL") == "" || os.Getenv("AZDO_PERSONAL_ACCESS_TOKEN") == "" {
		t.Skip("Skipping Azure DevOps tests: AZDO_ORG_SERVICE_URL and AZDO_PERSONAL_ACCESS_TOKEN are required")
	}

	if os.Getenv("AZDO_PROJECT_ID") == "" {
		t.Skip("Skipping Azure DevOps tests: AZDO_PROJECT_ID is required")
	}
}

func getProjectID(t testing.TB) string {
	t.Helper()

	return os.Getenv("AZDO_PROJECT_ID")
}

func destroyAllowMissingPipeline(t testing.TB, options *terraform.Options) {
	t.Helper()

	_, err := terraform.DestroyE(t, options)
	if err == nil {
		return
	}

	message := err.Error()
	if strings.Contains(message, "deleting authorized resource: Pipelines with ID(s)") &&
		strings.Contains(message, "could not be found") {
		t.Logf("Ignoring missing pipeline during destroy: %v", err)
		return
	}

	require.NoError(t, err)
}
