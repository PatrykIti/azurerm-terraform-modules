package test

import (
	"fmt"
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

type importTarget struct {
	address string
	id      string
}

func applyWithImportIfInstalled(t testing.TB, options *terraform.Options, targets []importTarget) (bool, error) {
	t.Helper()

	if err := terraform.InitAndApplyE(t, options); err != nil {
		if !isAlreadyInstalledError(err) {
			return false, err
		}

		if len(targets) == 0 {
			return false, err
		}

		t.Logf("Extension already installed; importing existing resource(s) into state")
		terraform.Init(t, options)
		for _, target := range targets {
			terraform.Import(t, options, target.address, target.id)
		}

		return false, nil
	}

	return true, nil
}

func isAlreadyInstalledError(err error) bool {
	if err == nil {
		return false
	}

	message := strings.ToLower(err.Error())
	return strings.Contains(message, "already installed") || strings.Contains(message, "tf1590010")
}

func buildBasicImportTargets(t testing.TB, vars map[string]interface{}) []importTarget {
	t.Helper()

	publisherID := stringFromVar(t, vars, "publisher_id")
	extensionID := stringFromVar(t, vars, "extension_id")
	return []importTarget{
		{
			address: "module.azuredevops_extension.azuredevops_extension.extension",
			id:      fmt.Sprintf("%s/%s", publisherID, extensionID),
		},
	}
}

func buildForEachImportTargets(t testing.TB, extensions []map[string]interface{}) []importTarget {
	t.Helper()

	targets := make([]importTarget, 0, len(extensions))
	for _, extension := range extensions {
		publisherID := stringFromVar(t, extension, "publisher_id")
		extensionID := stringFromVar(t, extension, "extension_id")
		key := fmt.Sprintf("%s/%s", publisherID, extensionID)
		targets = append(targets, importTarget{
			address: fmt.Sprintf("module.azuredevops_extension[%q].azuredevops_extension.extension", key),
			id:      key,
		})
	}

	return targets
}

func stringFromVar(t testing.TB, vars map[string]interface{}, key string) string {
	t.Helper()

	value, ok := vars[key]
	require.Truef(t, ok, "missing expected key %q in vars", key)
	stringValue, ok := value.(string)
	require.Truef(t, ok, "expected %q to be a string, got %T", key, value)
	return stringValue
}
