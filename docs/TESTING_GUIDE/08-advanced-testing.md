# Advanced Test Scenarios

Beyond basic integration tests, it is crucial to cover more advanced scenarios, such as performance, security, and policy compliance tests.

## Performance Testing

The `performance_test.go` file is dedicated to measuring and validating the module's performance.

### Creation Time Benchmarks

We use Go's built-in benchmarking mechanism to measure the time of `terraform apply` operations.

```go
// performance_test.go
func BenchmarkStorageAccountCreationSimple(b *testing.B) {
	b.ReportAllocs() // Reports memory allocations

	for i := 0; i < b.N; i++ {
		b.StopTimer() // Stop the timer during setup
		// ... setup (copying fixture, setting options)
		b.StartTimer() // Resume the timer just before the operation

		start := time.Now()
		terraform.InitAndApply(b, terraformOptions)
		creationTime := time.Since(start)

		b.StopTimer() // Stop again during cleanup
		terraform.Destroy(b, terraformOptions)
		b.StartTimer()

		// Report a metric that will appear in the benchmark results
		b.ReportMetric(float64(creationTime.Milliseconds()), "creation_ms")
	}
}
```
-   **`b.N`**: Go automatically adjusts the number of iterations to get a reliable result.
-   **`b.StopTimer()` / `b.StartTimer()`**: Key for measuring only the code snippet of interest.
-   **`b.ReportMetric`**: Allows adding custom metrics to the benchmark results.

### Deployment Time Tests

In addition to benchmarks, it's good to have a standard test that checks if the deployment time does not exceed a set threshold (SLA).

```go
// performance_test.go
func TestStorageAccountCreationTime(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	t.Parallel()

	// ... setup
	
	start := time.Now()
	terraform.InitAndApply(t, terraformOptions)
	duration := time.Since(start)

	// Define the maximum acceptable time
	maxDuration := 5 * time.Minute
	require.LessOrEqual(t, duration, maxDuration,
		"Storage account creation took %v, expected less than %v", duration, maxDuration)
}
```

## Security and Compliance Testing

These tests verify that the deployed resources meet security standards and company policies.

### Static Security Analysis (CI/CD)

Tools like `tfsec` and `checkov` are run in the CI/CD pipeline and are the first line of defense.

### Compliance Tests in Terratest

In `integration_test.go`, we can create a test that verifies key security aspects of a deployed resource.

```go
// integration_test.go
func TestStorageAccountCompliance(t *testing.T) {
	t.Parallel()
	// ... deploy resource from fixture/security

	helper := NewStorageAccountHelper(t)
	account := helper.GetStorageAccountProperties(t, storageAccountName, resourceGroupName)
	
	// Define a list of compliance checks
	complianceChecks := []struct {
		name      string
		check     func() bool
		message   string
	}{
		{
			name:    "HTTPS Only",
			check:   func() bool { return *account.Properties.EnableHTTPSTrafficOnly },
			message: "HTTPS-only traffic must be enforced",
		},
		{
			name:    "TLS Version",
			check:   func() bool { return *account.Properties.MinimumTLSVersion == armstorage.MinimumTLSVersionTLS12 },
			message: "Minimum TLS version must be 1.2",
		},
		// ... other checks
	}
	
	for _, cc := range complianceChecks {
		t.Run(cc.name, func(t *testing.T) {
			assert.True(t, cc.check(), cc.message)
		})
	}
}
```
This pattern makes it easy to add new compliance rules in the form of small, readable functions.

## Lifecycle Testing

Lifecycle tests verify how a resource behaves during updates and whether operations are idempotent.

```go
// integration_test.go
func TestStorageAccountLifecycle(t *testing.T) {
	// ...
	
	// 1. Initial deployment
	terraform.InitAndApply(t, terraformOptions)
	
	// 2. Verify initial state
	accountBeforeUpdate := helper.GetStorageAccountProperties(t, storageAccountName, resourceGroupName)
	assert.False(t, *accountBeforeUpdate.Properties.IsVersioningEnabled) // Assuming it's disabled by default

	// 3. Update configuration in Terraform variables
	terraformOptions.Vars["enable_blob_versioning"] = true
	terraform.Apply(t, terraformOptions)

	// 4. Verify that the change was applied
	accountAfterUpdate := helper.GetStorageAccountProperties(t, storageAccountName, resourceGroupName)
	assert.True(t, *accountAfterUpdate.Properties.IsVersioningEnabled)

	// 5. Test for idempotency
	// Running apply again with the same variables should result in no changes
	exitCode := terraform.Apply(t, terraformOptions)
	assert.Equal(t, 0, exitCode, "Second apply should show no changes")
}
```

## End-to-End (E2E) Tests

E2E tests verify the integration of several modules. Although there is no dedicated file, they can be placed in `integration_test.go` or in a separate directory at the repository level.

**Example E2E Scenario:**
1.  Deploy the `azurerm_virtual_network` module.
2.  Deploy the `azurerm_storage_account` module with a `private_endpoint` in a subnet from step 1.
3.  Deploy the `azurerm_virtual_machine` module in another subnet.
4.  Use `terratest/modules/ssh` to connect to the VM.
5.  From inside the VM, try to connect to the private IP address of the storage account to verify connectivity.
