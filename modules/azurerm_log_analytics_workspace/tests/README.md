# Log Analytics Workspace Module Tests

This directory contains automated tests for the Log Analytics Workspace Terraform module using [Terratest](https://terratest.gruntwork.io/).

## Prerequisites

1. **Go**: Version 1.21 or later
2. **Terraform**: Version 1.12.2 or later
3. **Azure Service Principal**: With Contributor access to the test subscription
4. **Azure CLI**: Optional, useful for troubleshooting/manual cleanup

## Environment Variables

Set the following environment variables before running tests:

```bash
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_LOCATION="West Europe"  # Optional, defaults to West Europe
export RUN_LOG_ANALYTICS_CLUSTER_TESTS="false"  # Optional, cluster tests are opt-in
```

## Running Tests

### Install Dependencies

```bash
go mod download
```

### Run All Tests

```bash
make test
```

### Compile/Discovery Check (no test execution)

```bash
go test ./... -run '^$'
```

### Run Basic Tests Only

```bash
make test-basic
```

### Run Integration Tests Only

```bash
make test-integration
```

### Run Specific Test

```bash
go test -v -run TestBasicLogAnalyticsWorkspace -timeout 30m
```

### Run Cluster Tests

Log Analytics dedicated clusters can take a long time to provision and may
require regional capacity/allowlisting. Cluster tests are disabled by default.

```bash
export RUN_LOG_ANALYTICS_CLUSTER_TESTS=true
go test -v -run TestLogAnalyticsClusters -timeout 180m
go test -v -run TestLogAnalyticsClusterCustomerManagedKey -timeout 180m
```

### Helper Script Behavior

`run_tests_parallel.sh` and `run_tests_sequential.sh` execute a fixed list of
tests and write JSON/log artifacts under `test_outputs/`. They continue on
individual test failures and are best for batch reporting, not fail-fast CI.

## Test Structure

### Test Files

- `log_analytics_workspace_test.go` - Main module functionality tests
- `integration_test.go` - Integration tests with Azure services
- `performance_test.go` - Performance and load tests
- `test_helpers.go` - Common test utilities and helpers
- `test_config.yaml` - Test configuration and scenarios

### Test Fixtures

The `fixtures/` directory contains Terraform configurations for different test scenarios:

- `fixtures/basic/` - Basic module configuration
- `fixtures/complete/` - Complete feature demonstration
- `fixtures/secure/` - Security-focused configuration
- `fixtures/solutions/` - Log Analytics solutions
- `fixtures/data-export-rules/` - Data export rules
- `fixtures/windows-event-datasource/` - Windows event data source
- `fixtures/windows-performance-counter/` - Windows performance counter data source
- `fixtures/storage-insights/` - Storage insights
- `fixtures/linked-services/` - Linked services
- `fixtures/clusters/` - Dedicated clusters
- `fixtures/cluster-cmk/` - Cluster CMK configuration
- `fixtures/negative/` - Negative test cases

## Debugging Tests

### Verbose Output

```bash
go test -v -run TestBasicLogAnalyticsWorkspace
```

### Keep Resources After Test Failure

Set the `SKIP_TEARDOWN` environment variable:

```bash
export SKIP_TEARDOWN=true
go test -v -run TestBasicLogAnalyticsWorkspace
```

### Debug Terraform

Enable Terraform debug logging:

```bash
export TF_LOG=DEBUG
go test -v -run TestBasicLogAnalyticsWorkspace
```

### Cleanup Orphaned Test Resources

If a test run is interrupted or times out, you can clean up leftover resources:

```bash
make cleanup-orphans
```

## Troubleshooting

### Common Issues

1. **Authentication Errors**: Verify Azure credentials and permissions
2. **Resource Conflicts**: Ensure unique resource naming
3. **Timeout Issues**: Increase test timeouts for complex scenarios
4. **Quota Limits**: Check Azure subscription quotas

### Getting Help

- Check the [Terratest documentation](https://terratest.gruntwork.io/)
- Review Azure provider documentation
- Check module-specific troubleshooting in the main README
