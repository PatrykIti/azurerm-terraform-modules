# Advanced Test Scenarios

Beyond validating the initial creation of resources, a robust test suite must cover advanced scenarios such as resource updates (lifecycle), compliance with security rules, disaster recovery capabilities, and performance. These tests are typically longer-running and are located in `integration_test.go` and `performance_test.go`.

**Note**: All advanced tests must be skippable in CI/CD for pull requests by including the `testing.Short()` check.

```go
func TestStorageAccountLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping advanced test in short mode")
	}
	// ...
}
```

## 1. Lifecycle and Idempotency Testing

Lifecycle tests verify that the module correctly handles updates to existing resources and that applying the same configuration multiple times produces no changes (idempotency).

**Test Steps:**
1.  Deploy a resource with an initial configuration.
2.  Verify the initial state.
3.  Modify a variable in the `terraform.Options` struct.
4.  Run `terraform.Apply(t, terraformOptions)` again to apply the update.
5.  Verify that the resource in Azure reflects the updated configuration.
6.  Run `terraform.Apply(t, terraformOptions)` one more time *with no changes* to ensure the operation is idempotent.

**Example (`integration_test.go`):**
```go
func TestStorageAccountLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_storage_account/tests/fixtures/simple")
	terraformOptions := getTerraformOptions(t, testFolder)
	
	defer terraform.Destroy(t, terraformOptions)

	// 1. Initial deployment with blob versioning disabled
	terraform.InitAndApply(t, terraformOptions)
	
	storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	helper := NewStorageAccountHelper(t)
	
	// 2. Verify initial state (versioning is false)
	blobServiceProps := helper.GetBlobServiceProperties(t, storageAccountName, resourceGroupName)
	assert.False(t, *blobServiceProps.IsVersioningEnabled)

	// 3. Update configuration to enable blob versioning
	terraformOptions.Vars["enable_blob_versioning"] = true
	terraform.Apply(t, terraformOptions)

	// 4. Verify the update was applied
	blobServicePropsAfterUpdate := helper.GetBlobServiceProperties(t, storageAccountName, resourceGroupName)
	assert.True(t, *blobServicePropsAfterUpdate.IsVersioningEnabled)

	// 5. Test for idempotency (this apply should result in no changes)
	terraform.Apply(t, terraformOptions)
}
```

## 2. Security and Compliance Testing

Compliance tests validate that a resource deployed with a security-focused configuration meets a predefined set of security rules. This is often done using a dedicated `security` fixture.

The recommended pattern is to create a slice of check structs, allowing for easy extension and clear, granular test results using `t.Run()`.

**Example (`integration_test.go`):**
```go
func TestStorageAccountCompliance(t *testing.T) {
	t.Parallel()
	// ... deploy resource from the "security" fixture ...

	helper := NewStorageAccountHelper(t)
	account := helper.GetStorageAccountProperties(t, storageAccountName, resourceGroupName)
	
	// Define a list of compliance checks to perform
	complianceChecks := []struct {
		name      string
		check     func() bool
		message   string
	}{
		{
			name:    "Enforce HTTPS Only",
			check:   func() bool { return *account.Properties.EnableHTTPSTrafficOnly },
			message: "HTTPS-only traffic must be enforced.",
		},
		{
			name:    "Require TLS 1.2",
			check:   func() bool { return *account.Properties.MinimumTLSVersion == armstorage.MinimumTLSVersionTLS12 },
			message: "Minimum TLS version must be 1.2.",
		},
		{
			name:    "Disable Public Blob Access",
			check:   func() bool { return !*account.Properties.AllowBlobPublicAccess },
			message: "Public blob access must be disabled.",
		},
	}
	
	// Run each check as a sub-test
	for _, cc := range complianceChecks {
		t.Run(cc.name, func(t *testing.T) {
			assert.True(t, cc.check(), cc.message)
		})
	}
}
```

## 3. Disaster Recovery Testing

These tests validate features related to high availability and geo-redundancy. This often involves configuring a specific replication type (like `GRS` or `RA-GRS`) and then using a "waiter" function to poll until the secondary location is available for reads.

**Example (`integration_test.go`):**
```go
func TestStorageAccountDisasterRecovery(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping disaster recovery test in short mode")
	}
	// ... setup ...
	
	// Use RA-GRS to enable read access from the secondary region
	terraformOptions.Vars["account_replication_type"] = "RAGRS"
	
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
	
	// ... get outputs ...
	helper := NewStorageAccountHelper(t)
	
	// 1. Wait for the secondary endpoint to become available
	helper.WaitForGRSSecondaryEndpoints(t, storageAccountName, resourceGroupName)
	
	// 2. Get the updated properties
	account := helper.GetStorageAccountProperties(t, storageAccountName, resourceGroupName)
	
	// 3. Validate the secondary endpoint
	require.NotNil(t, account.Properties.SecondaryEndpoints, "Secondary endpoints should be available for RA-GRS")
	require.NotEmpty(t, *account.Properties.SecondaryEndpoints.Blob, "Secondary blob endpoint should not be empty")
	assert.Contains(t, *account.Properties.SecondaryEndpoints.Blob, "-secondary.blob.core.")
}
```

## 4. Performance Testing

Performance tests are located in `performance_test.go` and use Go's built-in testing and benchmarking tools.

### Benchmarks

Benchmarks measure the time it takes to perform an action (like `terraform apply`) and are useful for tracking performance regressions over time.

**Example (`performance_test.go`):**
```go
func BenchmarkStorageAccountCreationSimple(b *testing.B) {
	// b.N is the number of iterations, managed by the Go test runner
	for i := 0; i < b.N; i++ {
		b.StopTimer() // Pause the timer for setup
		// ... setup test folder and terraformOptions ...
		b.StartTimer() // Resume the timer just before the measured operation

		terraform.InitAndApply(b, terraformOptions)

		b.StopTimer() // Pause again for cleanup
		terraform.Destroy(b, terraformOptions)
	}
}
```
**To run benchmarks:**
```bash
make benchmark
# or
go test -run=^$ -bench=.
```

### SLA Validation Tests

These are standard tests that validate the deployment time against a Service Level Agreement (SLA), such as "a simple storage account must be created in under 5 minutes."

**Example (`performance_test.go`):**
```go
func TestStorageAccountCreationTime(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	// ... setup ...
	
	start := time.Now()
	terraform.InitAndApply(t, terraformOptions)
	duration := time.Since(start)

	// Define and assert the SLA
	maxDuration := 5 * time.Minute
	require.LessOrEqual(t, duration, maxDuration, "Storage account creation took %v, expected less than %v", duration, maxDuration)
}
```