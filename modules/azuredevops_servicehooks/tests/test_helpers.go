package test

import (
	"os"
	"testing"
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
