# Contributing to Azure Storage Account Module

This guide covers specific contribution guidelines for the Azure Storage Account module. For general repository contribution guidelines, see the [main CONTRIBUTING.md](../../CONTRIBUTING.md).

## 📦 Module Overview

The Azure Storage Account module manages the lifecycle of Azure Storage Accounts with enterprise-grade features including:
- Security-by-default configuration
- Private endpoint support
- Customer-managed key encryption
- Static website hosting (via separate resource)
- Queue properties management (via separate resource)
- Lifecycle management rules

## 🏗️ Module Structure

```
modules/azurerm_storage_account/
├── .github/
│   └── module-config.yml     # Module metadata and CI configuration
├── main.tf                   # Core storage account and related resources
├── variables.tf              # Input variables with secure defaults
├── outputs.tf                # Output values including sensitive data
├── versions.tf               # Provider version requirements
├── README.md                 # Auto-generated documentation
├── CHANGELOG.md              # Version history
├── examples/
│   ├── simple/              # Basic usage example
│   ├── complete/            # All features example
│   ├── secure/              # Security-focused example
│   ├── secure-private-endpoint/ # Private endpoint example
│   └── multi-region/        # Multi-region deployment
└── tests/                    # Terratest integration tests
    ├── go.mod
    ├── storage_account_test.go
    └── test_helpers.go

## 🔧 Module-Specific Guidelines

### Important Deprecations (azurerm v5.0)

This module has been refactored to comply with azurerm provider v5.0:
- ❌ `static_website` block in `azurerm_storage_account` → ✅ `azurerm_storage_account_static_website` resource
- ❌ `queue_properties` block in `azurerm_storage_account` → ✅ `azurerm_storage_account_queue_properties` resource

Always use the separate resources for these features.

### Known Limitations

1. **Archive Tier + ZRS**: Archive lifecycle tier is not supported with Zone-Redundant Storage (ZRS)
2. **Diagnostic Categories**: Only metrics are supported at storage account level, not logs
3. **Private Endpoints**: Each storage service requires its own private endpoint

### CI/CD Integration

This module is integrated with the repository's automated workflows:

1. **Pull Request Checks**:
   - Automatic validation when changes are made
   - Security scanning with Checkov and Trivy
   - Test execution (if configured)
   - Documentation verification

2. **Documentation**:
   - README.md is auto-generated from terraform-docs
   - Updates are automated via `module-docs.yml`

3. **Testing**:
   - Tests run automatically on PR
   - Integration tests require Azure credentials

## 📝 Code Standards

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

## 🚀 Adding New Features

### 1. Check for Deprecations
Before implementing, verify the feature isn't deprecated in azurerm v5.0. Check if it requires a separate resource.

### 2. Variable Definition
Follow the established pattern with secure defaults:
```hcl
variable "new_feature" {
  description = "Configuration for the new feature. Set to null to disable."
  type = object({
    enabled = optional(bool, true)
    setting = optional(string, "secure_default")
  })
  default = {}
}
```

### 3. Implementation
For features requiring separate resources:
```hcl
resource "azurerm_storage_account_new_feature" "new_feature" {
  count = try(var.new_feature.enabled, false) ? 1 : 0
  
  storage_account_id = azurerm_storage_account.storage_account.id
  setting           = var.new_feature.setting
  
  depends_on = [
    azurerm_storage_account.storage_account
  ]
}
```

### 4. Output
```hcl
output "new_feature_id" {
  description = "The ID of the new feature"
  value       = try(azurerm_storage_account_new_feature.new_feature[0].id, null)
}
```

### 5. Update Examples
Add usage to at least the `complete` example:
```hcl
new_feature = {
  enabled = true
  setting = "custom_value"
}
```

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

## 🧪 Testing Requirements

### Example Testing
Each example must be tested before submission:
```bash
cd examples/simple
terraform init
terraform plan
terraform apply -auto-approve
# Verify resources in Azure Portal
terraform destroy -auto-approve
```

### Test Coverage Areas
1. **Basic Functionality**: Simple example
2. **All Features**: Complete example  
3. **Security**: Secure and secure-private-endpoint examples
4. **Multi-Region**: Multi-region example

### Common Test Scenarios
- Storage account with lifecycle rules (non-ZRS)
- Private endpoints for each storage service
- Customer-managed keys with Key Vault
- Static website hosting
- Queue logging configuration

## 📋 Module-Specific Checklist

Before submitting a PR for this module:

- [ ] Verified no deprecated blocks are used (static_website, queue_properties)
- [ ] Tested with azurerm provider 4.36.0
- [ ] All 5 examples tested and working
- [ ] Considered ZRS limitations for lifecycle rules
- [ ] Security defaults maintained (HTTPS only, TLS 1.2)
- [ ] Outputs use `try()` for conditional resources
- [ ] README.md regenerated with terraform-docs

## 🏷️ Release Process

This module uses independent versioning:
- **Tag Format**: `azurerm_storage_account/v<major>.<minor>.<patch>`
- **Example**: `azurerm_storage_account/v1.0.0`
- **Release Workflow**: Use the repository-wide `module-release.yml`

To release a new version:
1. Ensure all tests pass
2. Update CHANGELOG.md
3. Go to Actions → Module Release
4. Select `azurerm_storage_account` and provide version

## 📚 Module Resources

- [Azure Storage Account Documentation](https://docs.microsoft.com/azure/storage/common/storage-account-overview)
- [Terraform azurerm_storage_account Resource](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/storage_account)
- [Static Website Resource](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/storage_account_static_website)
- [Queue Properties Resource](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/storage_account_queue_properties)

## ❓ Need Help?

- Check existing issues for similar problems
- Review the examples for implementation patterns
- Consult the main [CONTRIBUTING.md](../../CONTRIBUTING.md) for general guidelines

Thank you for contributing to the Storage Account module!