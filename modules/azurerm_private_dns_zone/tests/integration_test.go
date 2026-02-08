package test

import (
	"os"
	"path/filepath"
	"testing"
)

// Integration coverage runs through the main Terratest suites that deploy real fixtures.
func TestPrivateDnsZoneIntegration(t *testing.T) {
	t.Parallel()

	requiredFixtures := []string{
		filepath.Join("fixtures", "basic", "main.tf"),
		filepath.Join("fixtures", "complete", "main.tf"),
		filepath.Join("fixtures", "secure", "main.tf"),
	}

	for _, fixture := range requiredFixtures {
		if _, err := os.Stat(fixture); err != nil {
			t.Fatalf("expected integration fixture %q to exist: %v", fixture, err)
		}
	}

	t.Log("Integration coverage is executed by TestBasicPrivateDnsZone, TestCompletePrivateDnsZone, and TestSecurePrivateDnsZone.")
}
