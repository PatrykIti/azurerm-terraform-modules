# Contributing to Azure Storage Account Module

Thank you for your interest in contributing to the Azure Storage Account Terraform module! This guide will help you get started.

## Development Setup

### Prerequisites
- Terraform >= 1.3.0
- Azure CLI
- Go >= 1.19 (for testing)
- terraform-docs
- tflint
- checkov (for security scanning)

### Local Development
1. Clone the repository
2. Install dependencies:
   ```bash
   # Install terraform-docs
   brew install terraform-docs
   
   # Install tflint
   brew install tflint
   
   # Install checkov
   pip install checkov
   ```

## Development Workflow

### 1. Create a Feature Branch
```bash
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes
- Update Terraform code
- Add/update tests
- Update documentation
- Update examples if needed

### 3. Validate Your Changes

#### Terraform Validation
```bash
# Format code
terraform fmt -recursive

# Initialize
terraform init -backend=false

# Validate
terraform validate
```

#### Linting
```bash
# Run tflint
tflint

# Run checkov security scan
checkov -d . --framework terraform
```

#### Documentation
```bash
# Generate documentation
./generate-docs.sh
```

### 4. Test Your Changes

#### Manual Testing
1. Navigate to an example directory
2. Create `terraform.tfvars` with your test values
3. Run:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

#### Automated Testing
```bash
cd tests
go mod init test
go mod tidy
go test -v -timeout 30m
```

## Code Standards

### Variable Naming
- Use descriptive names
- Use underscores for word separation
- Group related variables

### Variable Defaults
- Security-first defaults (e.g., `enable_https_traffic_only = true`)
- Use `null` for optional complex objects
- Document all defaults

### Resource Naming
- Use consistent prefixes
- Include type in name (e.g., `azurerm_storage_account.main`)

### Comments
- Document complex logic
- Explain security implications
- Reference Azure documentation

## Adding New Features

### 1. Variable Definition
```hcl
variable "new_feature_enabled" {
  description = "Enable the new feature. Requires XYZ."
  type        = bool
  default     = false
}
```

### 2. Implementation
```hcl
dynamic "new_feature" {
  for_each = var.new_feature_enabled ? [1] : []
  content {
    # Implementation
  }
}
```

### 3. Output
```hcl
output "new_feature_attribute" {
  description = "The new feature attribute"
  value       = try(azurerm_storage_account.main.new_feature[0].attribute, null)
}
```

### 4. Documentation
- Update README.md
- Add example usage
- Update CHANGELOG.md

### 5. Testing
- Add test case
- Update existing tests if needed

## Security Considerations

### Always
- Enable HTTPS-only by default
- Use latest TLS version
- Implement least privilege
- Document security implications

### Never
- Store secrets in code
- Use insecure defaults
- Bypass security validations

## Testing Guidelines

### Unit Tests
- Test each configuration variant
- Test validation rules
- Test error conditions

### Integration Tests
- Test with real Azure resources
- Test upgrade scenarios
- Test cross-feature interactions

### Example Test Structure
```go
func TestStorageAccountBasic(t *testing.T) {
    // Test implementation
}

func TestStorageAccountComplete(t *testing.T) {
    // Test implementation
}

func TestStorageAccountSecure(t *testing.T) {
    // Test implementation
}
```

## Pull Request Process

### PR Title
Use conventional commits format:
- `feat: Add support for X`
- `fix: Resolve issue with Y`
- `docs: Update README`
- `refactor: Simplify Z logic`

### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Terraform fmt
- [ ] Terraform validate
- [ ] tflint
- [ ] checkov
- [ ] Manual testing
- [ ] Automated tests

## Checklist
- [ ] CHANGELOG.md updated
- [ ] Documentation updated
- [ ] Examples updated
- [ ] Tests added/updated
```

### Review Process
1. Automated checks must pass
2. Code review by maintainer
3. Security review for sensitive changes
4. Testing confirmation

## Release Process

### Version Bump
Follow semantic versioning:
- Major: Breaking changes
- Minor: New features
- Patch: Bug fixes

### Release Steps
1. Update CHANGELOG.md
2. Update version in documentation
3. Create PR with release notes
4. Tag release after merge
5. Update module registry

## Getting Help

### Resources
- [Azure Storage Documentation](https://docs.microsoft.com/azure/storage/)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
- [Module Best Practices](../_docs/terraform-module-best-practices-guide.md)

### Communication
- Open an issue for bugs
- Discuss features before implementing
- Ask questions in discussions

## Code of Conduct

- Be respectful
- Be constructive
- Focus on the code
- Welcome newcomers

Thank you for contributing!