# Advanced Test Scenarios

Beyond validating the initial creation of resources, a robust test suite must cover advanced scenarios such as resource updates (lifecycle), compliance with security rules, disaster recovery capabilities, and performance. These tests are typically longer-running and are located in `integration_test.go` and `performance_test.go`.

**Note**: All advanced tests must be skippable in CI/CD for pull requests by including the `testing.Short()` check.

> Note: Legacy modules may still reference `fixtures/simple` or `fixtures/security`. New modules should use `fixtures/basic` and `fixtures/secure`.

```go
func TestKubernetesClusterLifecycle(t *testing.T) {
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
func TestKubernetesClusterLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_kubernetes_cluster/tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)
	
	defer terraform.Destroy(t, terraformOptions)

	// 1. Initial deployment
	terraform.InitAndApply(t, terraformOptions)
	
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	clusterName := terraform.Output(t, terraformOptions, "kubernetes_cluster_name")
	helper := NewKubernetesClusterHelper(t)
	
	// 2. Verify initial state (node count is 1)
	cluster := helper.GetKubernetesClusterProperties(t, resourceGroupName, clusterName)
	assert.Equal(t, int32(1), *(*cluster.Properties.AgentPoolProfiles[0]).Count)

	// 3. Update configuration to change node count
	terraformOptions.Vars["node_count"] = 2
	terraform.Apply(t, terraformOptions)

	// 4. Verify the update was applied
	clusterAfterUpdate := helper.GetKubernetesClusterProperties(t, resourceGroupName, clusterName)
	assert.Equal(t, int32(2), *(*clusterAfterUpdate.Properties.AgentPoolProfiles[0]).Count)

	// 5. Test for idempotency (this apply should result in no changes)
	terraform.Apply(t, terraformOptions)
}
```

## 2. Security and Compliance Testing

Compliance tests validate that a resource deployed with a security-focused configuration meets a predefined set of security rules. This is often done using a dedicated `secure` fixture.

The recommended pattern is to create a slice of check structs, allowing for easy extension and clear, granular test results using `t.Run()`.

**Example (`integration_test.go`):**
```go
func TestKubernetesClusterCompliance(t *testing.T) {
	t.Parallel()
	// ... deploy resource from the "secure" fixture ...

	helper := NewKubernetesClusterHelper(t)
	cluster := helper.GetKubernetesClusterProperties(t, resourceGroupName, clusterName)
	
	// Define a list of compliance checks to perform
	complianceChecks := []struct {
		name      string
		check     func() bool
		message   string
	}{
		{
			name:    "Private Cluster Enabled",
			check:   func() bool { return *cluster.Properties.APIServerAccessProfile.EnablePrivateCluster },
			message: "Private cluster must be enabled.",
		},
		{
			name:    "Azure Policy Enabled",
			check:   func() bool { return cluster.Properties.AddonProfiles["azurepolicy"] != nil && *cluster.Properties.AddonProfiles["azurepolicy"].Enabled },
			message: "Azure Policy add-on must be enabled.",
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

## 3. Feature-Specific Advanced Testing

These tests validate advanced, module-specific features beyond basic creation. For AKS, common examples include network profile validation, add-on enablement, or node pool behavior.

**Example (`integration_test.go`):**
```go
func TestKubernetesClusterNetworkProfile(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping advanced test in short mode")
	}
	// ... setup ...
	
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
	
	// ... get outputs ...
	helper := NewKubernetesClusterHelper(t)
	cluster := helper.GetKubernetesClusterProperties(t, resourceGroupName, clusterName)

	require.NotNil(t, cluster.Properties.NetworkProfile, "Network profile should be available")
	assert.Equal(t, armcontainerservice.NetworkPluginAzure, *cluster.Properties.NetworkProfile.NetworkPlugin)
	assert.Equal(t, armcontainerservice.NetworkPolicyAzure, *cluster.Properties.NetworkProfile.NetworkPolicy)
}
```

## 4. Performance Testing

Performance tests are located in `performance_test.go` and use Go's built-in testing and benchmarking tools.

### Benchmarks

Benchmarks measure the time it takes to perform an action (like `terraform apply`) and are useful for tracking performance regressions over time.

**Example (`performance_test.go`):**
```go
func BenchmarkKubernetesClusterCreation(b *testing.B) {
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

These are standard tests that validate the deployment time against a Service Level Agreement (SLA), such as "a basic AKS cluster must be created in under 20 minutes."

**Example (`performance_test.go`):**
```go
func TestKubernetesClusterCreationTime(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	// ... setup ...
	
	start := time.Now()
	terraform.InitAndApply(t, terraformOptions)
	duration := time.Since(start)

	// Define and assert the SLA
	maxDuration := 20 * time.Minute
	require.LessOrEqual(t, duration, maxDuration, "Kubernetes cluster creation took %v, expected less than %v", duration, maxDuration)
}
```
