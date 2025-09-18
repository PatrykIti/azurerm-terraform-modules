# Azure Subnet Module Tests

This directory contains test files for the Azure Subnet module.

## Test Structure

### Native Terraform Tests

The module uses native Terraform test framework (`.tftest.hcl` files) for unit testing. Due to Terraform 1.11.x limitations, test files are located at the module root directory rather than in subdirectories.

Test files at module root:
- `basic.tftest.hcl` - Basic subnet creation and default values
- `associations.tftest.hcl` - NSG and Route Table associations
- `network_policies.tftest.hcl` - Private endpoint and private link service policies
- `service_endpoints.tftest.hcl` - Service endpoints, policies, and delegations
- `validation.tftest.hcl` - Input validation tests

### Running Tests

From the module directory:

```bash
# Initialize the module
terraform init

# Run all tests
terraform test

# Run a specific test file
terraform test -filter=basic.tftest.hcl
```

### Test Coverage

The tests cover:
1. **Basic functionality** - Subnet creation with required parameters
2. **Default values** - Verification of secure defaults
3. **Associations** - NSG and Route Table association logic
4. **Network policies** - Private endpoint and private link service policies
5. **Service endpoints** - Endpoint configuration and policies
6. **Delegations** - Subnet delegation to Azure services
7. **Input validation** - Parameter validation rules
8. **Outputs** - All module outputs

### Integration Tests

Integration tests using Terratest are planned for future implementation in the `integration/` directory.
EOF < /dev/null