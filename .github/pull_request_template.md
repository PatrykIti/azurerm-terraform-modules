## Description

<!-- Provide a brief description of the changes in this PR -->

## Related Issue

<!-- Link to the issue this PR addresses (if applicable) -->
Fixes #(issue number)

## Type of Change

<!-- Mark the relevant option with an "x" -->
- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] 🚀 New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📚 Documentation update
- [ ] 🔧 Refactoring (no functional changes)
- [ ] 🧪 Test improvement
- [ ] 🔒 Security fix

## Module(s) Affected

<!-- List the modules affected by this change -->
- [ ] azurerm_storage_account
- [ ] azurerm_virtual_network
- [ ] azurerm_key_vault
- [ ] Other: 

## Testing

### Test Configuration
<!-- Describe the test configuration used -->
- Terraform version:
- Provider version:
- Test environment:

### Test Results
<!-- Provide evidence of testing -->
- [ ] `terraform fmt` - Passed
- [ ] `terraform init` - Passed
- [ ] `terraform validate` - Passed
- [ ] `terraform plan` - Passed
- [ ] `terraform apply` - Passed
- [ ] `terraform destroy` - Passed

### Example Output
<details>
<summary>Terraform Plan Output</summary>

```hcl
# Paste relevant terraform plan output here
```

</details>

## Checklist

### General
- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings

### Module Specific
- [ ] I have updated the module's README.md using `terraform-docs`
- [ ] I have added/updated examples demonstrating the new functionality
- [ ] I have updated the CHANGELOG.md (if applicable)
- [ ] I have tested all examples in the module
- [ ] I have considered backwards compatibility

### Security
- [ ] I have not introduced any security vulnerabilities
- [ ] All defaults follow security best practices
- [ ] Sensitive outputs are marked as sensitive
- [ ] No secrets or credentials are hardcoded

### CI/CD
- [ ] All GitHub Actions workflows pass
- [ ] Module-specific validation passes
- [ ] Security scans show no new vulnerabilities

## Screenshots (if applicable)

<!-- Add screenshots to help explain your changes -->

## Additional Notes

<!-- Add any additional notes or context about the PR here -->

---

By submitting this PR, I confirm that my contribution is made under the terms of the Apache 2.0 license.