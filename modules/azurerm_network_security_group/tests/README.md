# Network Security Group Module Tests

This directory contains automated tests for the Azure Network Security Group Terraform module.

## Test Structure

```
tests/
├── unit/                      # Native Terraform test framework tests
│   ├── basic.tftest.hcl      # Basic functionality tests
│   ├── security_rules.tftest.hcl # Security rules tests
│   └── validation.tftest.hcl # Input validation tests
├── integration/              # Terratest integration tests (Go)
│   ├── network_security_group_test.go      # Main integration tests
│   ├── network_security_group_perf_test.go # Performance tests
│   └── test_helpers.go      # Test utility functions
├── fixtures/                # Test fixtures
│   └── basic-nsg.tf        # Basic NSG test fixture
├── go.mod                  # Go module dependencies
└── README.md              # This file
```

## Running Tests

### Unit Tests (Native Terraform Tests)

Run all unit tests:
```bash
terraform test
```

Run specific test file:
```bash
terraform test -filter=tests/unit/basic.tftest.hcl
```

### Integration Tests (Terratest)

Prerequisites:
- Go 1.20 or later
- Azure credentials configured
- Terraform installed

Set up environment:
```bash
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_TENANT_ID="your-tenant-id"
```

Run all integration tests:
```bash
cd tests
go mod download
go test -v ./integration/...
```

Run specific test:
```bash
go test -v -run TestNetworkSecurityGroupBasic ./integration/
```

Run tests with timeout:
```bash
go test -v -timeout 30m ./integration/...
```

### Performance Tests

Performance tests are skipped by default. To run them:
```bash
go test -v -run TestNetworkSecurityGroupPerformance ./integration/
```

## Test Coverage

### Unit Tests
- Basic NSG creation
- Default values validation
- Output verification
- Security rule validation
- Network policy defaults

### Integration Tests
- **Basic NSG**: Simple NSG with basic rules
- **Complete NSG**: All features including flow logs and traffic analytics
- **Security Rules**: Various rule configurations and patterns
- **Input Validation**: Invalid input handling
- **Performance**: Large number of rules and concurrent deployments

## Writing New Tests

### Unit Tests
1. Create a new `.tftest.hcl` file in `tests/unit/`
2. Use mock providers to avoid real resource creation
3. Focus on module logic and validation

Example:
```hcl
run "test_new_feature" {
  command = plan
  
  variables = {
    # Test inputs
  }
  
  assert {
    condition     = # Your condition
    error_message = "Descriptive error message"
  }
}
```

### Integration Tests
1. Add test functions to existing test files or create new ones
2. Use unique resource names with `random.UniqueId()`
3. Always clean up resources with `defer terraform.Destroy()`
4. Use parallel testing where possible

Example:
```go
func TestNewFeature(t *testing.T) {
    t.Parallel()
    
    uniqueID := random.UniqueId()
    // ... test implementation
    
    defer terraform.Destroy(t, terraformOptions)
    // ... assertions
}
```

## CI/CD Integration

### GitHub Actions Example
```yaml
- name: Run Terraform Unit Tests
  run: terraform test
  
- name: Run Terratest Integration Tests
  env:
    ARM_SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTION_ID }}
    ARM_CLIENT_ID: ${{ secrets.ARM_CLIENT_ID }}
    ARM_CLIENT_SECRET: ${{ secrets.ARM_CLIENT_SECRET }}
    ARM_TENANT_ID: ${{ secrets.ARM_TENANT_ID }}
  run: |
    cd modules/azurerm_network_security_group/tests
    go test -v -short -timeout 30m ./integration/...
```

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Ensure Azure credentials are properly set
   - Check subscription permissions

2. **Resource Already Exists**
   - Previous test may have failed to clean up
   - Manually delete orphaned resources
   - Use unique naming with timestamps

3. **Timeout Errors**
   - Increase test timeout: `-timeout 60m`
   - Check Azure service health
   - Reduce test scope for debugging

4. **Module Not Found**
   - Run `go mod download` to fetch dependencies
   - Ensure correct module path in go.mod

## Best Practices

1. **Resource Naming**: Always use unique names with `random.UniqueId()`
2. **Cleanup**: Always use `defer` for resource cleanup
3. **Parallel Testing**: Use `t.Parallel()` for faster execution
4. **Error Handling**: Check for both Terraform and Azure errors
5. **Assertions**: Use meaningful assertion messages
6. **Tags**: Tag all test resources for easy identification