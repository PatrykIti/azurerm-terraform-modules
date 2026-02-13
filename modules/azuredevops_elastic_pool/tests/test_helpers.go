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
}

func requireADOElasticEnv(t testing.TB) {
	t.Helper()

	requireADOEnv(t)

	if os.Getenv("AZDO_TEST_SERVICE_ENDPOINT_ID") == "" ||
		os.Getenv("AZDO_TEST_SERVICE_ENDPOINT_SCOPE") == "" ||
		os.Getenv("AZDO_TEST_AZURE_RESOURCE_ID") == "" {
		t.Skip("Skipping Azure DevOps elastic pool tests: AZDO_TEST_SERVICE_ENDPOINT_ID, AZDO_TEST_SERVICE_ENDPOINT_SCOPE, and AZDO_TEST_AZURE_RESOURCE_ID are required")
	}
}
