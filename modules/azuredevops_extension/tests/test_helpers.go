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

	if os.Getenv("AZDO_EXTENSION_PUBLISHER_ID") == "" || os.Getenv("AZDO_EXTENSION_ID") == "" {
		t.Skip("Skipping Azure DevOps tests: AZDO_EXTENSION_PUBLISHER_ID and AZDO_EXTENSION_ID are required")
	}
}

func getExtensionVarsFromEnv() map[string]interface{} {
	vars := map[string]interface{}{
		"publisher_id": os.Getenv("AZDO_EXTENSION_PUBLISHER_ID"),
		"extension_id": os.Getenv("AZDO_EXTENSION_ID"),
	}

	if version := os.Getenv("AZDO_EXTENSION_VERSION"); version != "" {
		vars["extension_version"] = version
	}

	return vars
}

func getExtensionsFromEnv() []map[string]interface{} {
	extensions := []map[string]interface{}{}

	primary := map[string]interface{}{
		"publisher_id": os.Getenv("AZDO_EXTENSION_PUBLISHER_ID"),
		"extension_id": os.Getenv("AZDO_EXTENSION_ID"),
	}
	if version := os.Getenv("AZDO_EXTENSION_VERSION"); version != "" {
		primary["version"] = version
	}
	extensions = append(extensions, primary)

	if os.Getenv("AZDO_EXTENSION_PUBLISHER_ID_2") != "" && os.Getenv("AZDO_EXTENSION_ID_2") != "" {
		secondary := map[string]interface{}{
			"publisher_id": os.Getenv("AZDO_EXTENSION_PUBLISHER_ID_2"),
			"extension_id": os.Getenv("AZDO_EXTENSION_ID_2"),
		}
		if version := os.Getenv("AZDO_EXTENSION_VERSION_2"); version != "" {
			secondary["version"] = version
		}
		extensions = append(extensions, secondary)
	}

	return extensions
}
