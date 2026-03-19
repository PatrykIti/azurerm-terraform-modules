package test

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// TestConfig holds common test configuration.
// NOTE: Keep in sync with test_env.sh and CI secrets.
type TestConfig struct {
	SubscriptionID string
	TenantID       string
	ClientID       string
	ClientSecret   string
	Location       string
	ResourceGroup  string
	UniqueID       string
}

// GetTestConfig returns a normalized test configuration using ARM_* / AZURE_* env vars.
func GetTestConfig(t *testing.T) *TestConfig {
	subscriptionID := coalesceEnv(
		strings.TrimSpace(os.Getenv("ARM_SUBSCRIPTION_ID")),
		strings.TrimSpace(os.Getenv("AZURE_SUBSCRIPTION_ID")),
	)
	require.NotEmpty(t, subscriptionID, "ARM_SUBSCRIPTION_ID or AZURE_SUBSCRIPTION_ID environment variable must be set")

	tenantID := coalesceEnv(
		strings.TrimSpace(os.Getenv("ARM_TENANT_ID")),
		strings.TrimSpace(os.Getenv("AZURE_TENANT_ID")),
	)
	require.NotEmpty(t, tenantID, "ARM_TENANT_ID or AZURE_TENANT_ID environment variable must be set")

	clientID := coalesceEnv(
		strings.TrimSpace(os.Getenv("ARM_CLIENT_ID")),
		strings.TrimSpace(os.Getenv("AZURE_CLIENT_ID")),
	)
	require.NotEmpty(t, clientID, "ARM_CLIENT_ID or AZURE_CLIENT_ID environment variable must be set")

	clientSecret := coalesceEnv(
		strings.TrimSpace(os.Getenv("ARM_CLIENT_SECRET")),
		strings.TrimSpace(os.Getenv("AZURE_CLIENT_SECRET")),
	)
	require.NotEmpty(t, clientSecret, "ARM_CLIENT_SECRET or AZURE_CLIENT_SECRET environment variable must be set")

	location := coalesceEnv(
		strings.TrimSpace(os.Getenv("ARM_LOCATION")),
		strings.TrimSpace(os.Getenv("AZURE_LOCATION")),
		"westeurope",
	)

	uniqueID := strings.ToLower(random.UniqueId())

	return &TestConfig{
		SubscriptionID: subscriptionID,
		TenantID:       tenantID,
		ClientID:       clientID,
		ClientSecret:   clientSecret,
		Location:       location,
		ResourceGroup:  fmt.Sprintf("rg-test-managed-redis-%s", uniqueID),
		UniqueID:       uniqueID,
	}
}

// WaitForResourceDeletion waits for a resource to be deleted.
func WaitForResourceDeletion(ctx context.Context, checkFunc func() (bool, error), timeout time.Duration) error {
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()

	timeoutCh := time.After(timeout)

	for {
		select {
		case <-timeoutCh:
			return fmt.Errorf("timeout waiting for resource deletion")
		case <-ticker.C:
			exists, err := checkFunc()
			if err != nil {
				return fmt.Errorf("error checking resource existence: %w", err)
			}
			if !exists {
				return nil
			}
		}
	}
}

// GenerateResourceName generates a unique resource name for testing.
func GenerateResourceName(prefix string, uniqueID string) string {
	name := fmt.Sprintf("%s%s", prefix, uniqueID)
	name = strings.ReplaceAll(name, "-", "")
	if len(name) > 63 {
		name = name[:63]
	}
	return strings.ToLower(name)
}

// PrepareTerraformWorkingDirs removes local Terraform artifacts from copied fixtures.
// This prevents stale module snapshots in .terraform from previous runs.
func PrepareTerraformWorkingDirs(t testing.TB, terraformDir string) {
	t.Helper()

	moduleRoot := filepath.Clean(filepath.Join(terraformDir, "../../.."))
	moduleCacheRoot := filepath.Clean(filepath.Join(terraformDir, ".."))

	pathsToClean := []string{
		filepath.Join(terraformDir, ".terraform"),
		filepath.Join(terraformDir, ".terraform.lock.hcl"),
		filepath.Join(terraformDir, "terraform.tfstate"),
		filepath.Join(terraformDir, "terraform.tfstate.backup"),
		filepath.Join(terraformDir, ".terraform.tfstate.lock.info"),
		filepath.Join(terraformDir, "crash.log"),
		filepath.Join(moduleCacheRoot, ".terraform"),
		filepath.Join(moduleCacheRoot, ".terraform.lock.hcl"),
		filepath.Join(moduleRoot, ".terraform"),
		filepath.Join(moduleRoot, ".terraform.lock.hcl"),
	}

	for _, path := range pathsToClean {
		if err := os.RemoveAll(path); err != nil {
			t.Fatalf("failed to clean terraform artifact %s: %v", path, err)
		}
	}
}

// NormalizedTerraformEnv maps AZURE_* credentials to ARM_* when needed.
func NormalizedTerraformEnv() map[string]string {
	env := map[string]string{
		"TF_CLI_ARGS_apply": "-parallelism=1",
	}

	setIfPresent := func(key, value string) {
		if strings.TrimSpace(value) != "" {
			env[key] = value
		}
	}

	armSubscription := strings.TrimSpace(os.Getenv("ARM_SUBSCRIPTION_ID"))
	armTenant := strings.TrimSpace(os.Getenv("ARM_TENANT_ID"))
	armClient := strings.TrimSpace(os.Getenv("ARM_CLIENT_ID"))
	armSecret := strings.TrimSpace(os.Getenv("ARM_CLIENT_SECRET"))
	armLocation := strings.TrimSpace(os.Getenv("ARM_LOCATION"))

	azureSubscription := strings.TrimSpace(os.Getenv("AZURE_SUBSCRIPTION_ID"))
	azureTenant := strings.TrimSpace(os.Getenv("AZURE_TENANT_ID"))
	azureClient := strings.TrimSpace(os.Getenv("AZURE_CLIENT_ID"))
	azureSecret := strings.TrimSpace(os.Getenv("AZURE_CLIENT_SECRET"))
	azureLocation := strings.TrimSpace(os.Getenv("AZURE_LOCATION"))

	setIfPresent("ARM_SUBSCRIPTION_ID", coalesceEnv(armSubscription, azureSubscription))
	setIfPresent("ARM_TENANT_ID", coalesceEnv(armTenant, azureTenant))
	setIfPresent("ARM_CLIENT_ID", coalesceEnv(armClient, azureClient))
	setIfPresent("ARM_CLIENT_SECRET", coalesceEnv(armSecret, azureSecret))
	setIfPresent("AZURE_SUBSCRIPTION_ID", coalesceEnv(azureSubscription, armSubscription))
	setIfPresent("AZURE_TENANT_ID", coalesceEnv(azureTenant, armTenant))
	setIfPresent("AZURE_CLIENT_ID", coalesceEnv(azureClient, armClient))
	setIfPresent("AZURE_CLIENT_SECRET", coalesceEnv(azureSecret, armSecret))
	setIfPresent("ARM_LOCATION", coalesceEnv(armLocation, azureLocation))
	setIfPresent("AZURE_LOCATION", coalesceEnv(azureLocation, armLocation))

	return env
}

func coalesceEnv(values ...string) string {
	for _, value := range values {
		if strings.TrimSpace(value) != "" {
			return value
		}
	}
	return ""
}

// GetTestConfigForOptions returns a non-testing variant of TestConfig for benchmark/setup code.
func GetTestConfigForOptions() *TestConfig {
	location := coalesceEnv(
		strings.TrimSpace(os.Getenv("ARM_LOCATION")),
		strings.TrimSpace(os.Getenv("AZURE_LOCATION")),
		"northeurope",
	)

	timestamp := time.Now().UnixNano() % 1000
	baseID := strings.ToLower(random.UniqueId())
	uniqueID := fmt.Sprintf("%s%03d", baseID[:5], timestamp)

	return &TestConfig{
		SubscriptionID: coalesceEnv(strings.TrimSpace(os.Getenv("ARM_SUBSCRIPTION_ID")), strings.TrimSpace(os.Getenv("AZURE_SUBSCRIPTION_ID"))),
		TenantID:       coalesceEnv(strings.TrimSpace(os.Getenv("ARM_TENANT_ID")), strings.TrimSpace(os.Getenv("AZURE_TENANT_ID"))),
		ClientID:       coalesceEnv(strings.TrimSpace(os.Getenv("ARM_CLIENT_ID")), strings.TrimSpace(os.Getenv("AZURE_CLIENT_ID"))),
		ClientSecret:   coalesceEnv(strings.TrimSpace(os.Getenv("ARM_CLIENT_SECRET")), strings.TrimSpace(os.Getenv("AZURE_CLIENT_SECRET"))),
		Location:       location,
		ResourceGroup:  fmt.Sprintf("rg-test-managed-redis-%s", uniqueID),
		UniqueID:       uniqueID,
	}
}

// NewTerraformOptions returns normalized Terratest options with retries and env wiring.
func NewTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	t.Helper()
	PrepareTerraformWorkingDirs(t, terraformDir)

	testConfig := GetTestConfigForOptions()

	location := coalesceEnv(
		testConfig.Location,
		"northeurope",
	)

	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"random_suffix": testConfig.UniqueID,
			"location":      location,
		},
		EnvVars: NormalizedTerraformEnv(),
		NoColor: true,
		RetryableTerraformErrors: map[string]string{
			".*timeout.*":                          "Timeout error - retrying",
			".*ResourceGroupNotFound.*":            "Resource group not found - retrying",
			".*AlreadyExists.*":                    "Resource already exists - retrying",
			".*TooManyRequests.*":                  "Too many requests - retrying",
			".*InternalServerError.*":              "Internal server error - retrying",
			".*ServiceUnavailable.*":               "Service unavailable - retrying",
			".*Conflict.*":                         "Conflict error - retrying",
			".*another operation is in progress.*": "Concurrent Azure operation in progress - retrying",
			".*operation.*in progress.*":           "Operation already in progress - retrying",
			".*OperationTimedOut.*":                "Operation timed out - retrying",
			".*context deadline exceeded.*":        "Context deadline exceeded - retrying",
			".*transport is closing.*":             "Transient transport close - retrying",
		},
		MaxRetries:         8,
		TimeBetweenRetries: 30 * time.Second,
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
