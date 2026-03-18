package test

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// PrepareTerraformWorkingDirs removes local Terraform artifacts from copied fixtures.
// This prevents stale module snapshots in .terraform from previous runs.
func PrepareTerraformWorkingDirs(t testing.TB, terraformDir string) {
	t.Helper()

	moduleRoot := filepath.Clean(filepath.Join(terraformDir, "../../.."))

	pathsToClean := []string{
		filepath.Join(terraformDir, ".terraform"),
		filepath.Join(terraformDir, ".terraform.lock.hcl"),
		filepath.Join(terraformDir, "terraform.tfstate"),
		filepath.Join(terraformDir, "terraform.tfstate.backup"),
		filepath.Join(terraformDir, "crash.log"),
		filepath.Join(moduleRoot, ".terraform"),
		filepath.Join(moduleRoot, ".terraform.lock.hcl"),
	}

	for _, path := range pathsToClean {
		if err := os.RemoveAll(path); err != nil {
			t.Fatalf("failed to clean terraform artifact %s: %v", path, err)
		}
	}
}

// OutputString returns a trimmed Terraform string output.
func OutputString(t testing.TB, terraformOptions *terraform.Options, name string) string {
	t.Helper()
	return strings.TrimSpace(terraform.Output(t, terraformOptions, name))
}

// OutputList returns a Terraform list output as a Go slice.
func OutputList(t testing.TB, terraformOptions *terraform.Options, name string) []string {
	t.Helper()
	values := terraform.OutputList(t, terraformOptions, name)
	require.NotNil(t, values, "output %q should not be nil", name)
	return values
}
