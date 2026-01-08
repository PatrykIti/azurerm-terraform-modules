package test

import (
    "testing"

    test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

// Placeholder test that skips by default (module requires real Azure DevOps resources)
func TestAzuredevopsSecurityroleAssignment(t *testing.T) {
    t.Skip("Skipping: integration requires real Azure DevOps environment")

    _ = test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
}
