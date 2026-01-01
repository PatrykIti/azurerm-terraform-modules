# Terratest Go File Structure

A standardized structure within the Go test files (`*_test.go`) is essential for consistency and maintainability. This guide outlines the roles of the main test file, the integration test file, and the performance test file, using the `azurerm_kubernetes_cluster` module as the reference implementation.

## 1. Main Test File: `{module_name}_test.go`

This is the primary file for testing the module's core functionality. It should contain tests for the most common and critical scenarios defined in the `fixtures` directory.

-   **Purpose**: To provide fast feedback on the main features of the module. These tests are expected to run on every pull request.
-   **File Name**: `kubernetes_cluster_test.go` (for the `azurerm_kubernetes_cluster` module).

### Key Characteristics

-   **One Test Function per Fixture**: Each major fixture (e.g., `basic`, `complete`, `secure`, `network`) should have its own `Test...` function.
-   **Parallel Execution**: All test functions in this file must run in parallel using `t.Parallel()`.
-   **Use of `test-structure`**: Each test must follow the `setup -> deploy -> validate -> cleanup` pattern using `test_structure` to ensure robustness.
-   **Validation via Helpers**: The `validate` stage should call validation functions from `test_helpers.go` rather than containing raw SDK calls. For Azure DevOps modules, helpers may only validate outputs or call REST APIs.

> Note: Legacy modules may still use `simple`/`security` fixture names. New modules should use `basic`/`secure`.

### Example: Basic Scenario Test

```go
// in kubernetes_cluster_test.go
func TestBasicKubernetesCluster(t *testing.T) {
	t.Parallel()

	// 1. Setup: Copy the fixture to a temp folder
	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	
	// 2. Defer Cleanup
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	// 3. Deploy
	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	// 4. Validate
	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		clusterName := terraform.Output(t, terraformOptions, "kubernetes_cluster_name")

		// Use the helper to get resource properties
		helper := NewKubernetesClusterHelper(t)
		cluster := helper.GetKubernetesClusterProperties(t, resourceGroupName, clusterName)
		
		// Assertions
		assert.Equal(t, "Succeeded", string(*cluster.Properties.ProvisioningState))
		assert.Equal(t, armcontainerservice.ResourceIdentityTypeSystemAssigned, *cluster.Identity.Type)
	})
}
```

### Example: Negative Validation Test

This file should also contain the test function for all negative test cases, which iterates through fixtures that are expected to fail.

```go
// in kubernetes_cluster_test.go
func TestKubernetesClusterValidationRules(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name          string
		fixtureFolder string
		expectedError string
	}{
		{
			name:          "InvalidName",
			fixtureFolder: "negative",
			expectedError: "must be between 1 and 63 characters long",
		},
		// ... other negative test cases
	}

	for _, tc := range testCases {
		tc := tc // Capture range variable
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			// Copy the specific negative fixture
			testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/"+tc.fixtureFolder)
			
			terraformOptions := &terraform.Options{
				TerraformDir: testFolder,
			}

			// Expect `terraform plan` to fail with a specific error
			_, err := terraform.InitAndPlanE(t, terraformOptions)
			require.Error(t, err)
			assert.Contains(t, err.Error(), tc.expectedError)
		})
	}
}
```

## 2. Advanced Tests: `integration_test.go`

This file is dedicated to more complex, longer-running tests that are not suitable for execution on every pull request.

-   **Purpose**: To test resource lifecycle (updates, idempotency), disaster recovery, and complex compliance scenarios.
-   **File Name**: `integration_test.go`

### Key Characteristics

-   **Skip in Short Mode**: All tests in this file must include a check to be skipped when the `-short` flag is used in `go test`. This allows CI/CD to run them only on main/release branches.
-   **Focus on Behavior**: These tests focus on how a resource behaves after its initial creation.

### Example: Lifecycle and Idempotency Test

```go
// in integration_test.go
func TestKubernetesClusterLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)
	
	defer terraform.Destroy(t, terraformOptions)

	// 1. Initial deployment
	terraform.InitAndApply(t, terraformOptions)
	
	// 2. Update configuration in variables
	terraformOptions.Vars["node_count"] = 2
	terraform.Apply(t, terraformOptions)

	// 3. Verify the update was applied using a helper
	helper := NewKubernetesClusterHelper(t)
	// ... validation logic ...

	// 4. Test for idempotency by applying again with no changes
	terraform.Apply(t, terraformOptions)
}
```

## 3. Performance Tests: `performance_test.go`

This file contains Go benchmarks and tests that validate performance and deployment time SLAs.

-   **Purpose**: To track the performance of the module over time and prevent regressions.
-   **File Name**: `performance_test.go`

### Key Characteristics

-   **Skip in Short Mode**: All tests must be skipped in `-short` mode.
-   **Benchmarks**: Use `Benchmark...` functions to measure performance metrics.
-   **SLA Tests**: Use `Test...` functions to assert that deployment time is within an acceptable range.

### Example: Creation Time Benchmark

```go
// in performance_test.go
func BenchmarkKubernetesClusterCreation(b *testing.B) {
	b.ReportAllocs()

	for i := 0; i < b.N; i++ {
		b.StopTimer() // Pause timer for setup
		testFolder := test_structure.CopyTerraformFolderToTemp(b, "..", "tests/fixtures/basic")
		terraformOptions := getTerraformOptions(b, testFolder)
		b.StartTimer() // Resume timer for the operation

		// The code to be measured
		terraform.InitAndApply(b, terraformOptions)

		b.StopTimer() // Pause timer for cleanup
		terraform.Destroy(b, terraformOptions)
	}
}
```

### Example: Deployment Time SLA Test

```go
// in performance_test.go
func TestKubernetesClusterCreationTime(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	t.Parallel()

	// ... setup ...
	
	start := time.Now()
	terraform.InitAndApply(t, terraformOptions)
	duration := time.Since(start)

	// Define and assert the SLA
	maxDuration := 20 * time.Minute
	require.LessOrEqual(t, duration, maxDuration, "Kubernetes cluster creation took too long")
}
```
