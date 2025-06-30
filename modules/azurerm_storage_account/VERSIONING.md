# Module Versioning Guide

## Version Format

This module follows a custom semantic versioning format:

```
SAv{major}.{minor}.{patch}
```

Where:
- `SA` = Storage Account module identifier
- `v` = version prefix
- `{major}.{minor}.{patch}` = semantic version numbers

### Examples:
- `SAv1.0.0` - First stable release
- `SAv1.1.0` - Minor feature addition
- `SAv1.0.1` - Bug fix
- `SAv2.0.0` - Breaking change

## Version Number Guidelines

### Major Version (Breaking Changes)
Increment when:
- Removing variables or outputs
- Changing variable types or defaults in incompatible ways
- Removing resources
- Changing resource naming conventions
- Minimum Terraform version increase that drops support

Examples:
- Changing `enable_https_traffic_only` default from `true` to `false`
- Removing support for `account_kind = "Storage"`
- Renaming core variables without deprecation period

### Minor Version (New Features)
Increment when:
- Adding new variables (with defaults)
- Adding new outputs
- Adding new resources (optional)
- Adding new capabilities
- Non-breaking improvements

Examples:
- Adding `enable_nfs_v3` variable
- Adding support for new Azure features
- Adding new lifecycle rule options

### Patch Version (Bug Fixes)
Increment when:
- Fixing bugs
- Updating documentation
- Improving error messages
- Performance improvements
- Security patches (non-breaking)

Examples:
- Fixing incorrect validation rules
- Correcting resource dependencies
- Documentation typos

## Release Process

### 1. Pre-release Checklist
- [ ] All tests passing
- [ ] Documentation updated
- [ ] Examples tested
- [ ] CHANGELOG.md updated
- [ ] Version number decided

### 2. Version Tagging
```bash
# Create annotated tag
git tag -a SAv1.0.0 -m "Release version SAv1.0.0"

# Push tag
git push origin SAv1.0.0
```

### 3. Release Notes Template
```markdown
## SAv1.0.0 - Storage Account Module Release

### Highlights
- Brief summary of major changes

### New Features
- Feature 1
- Feature 2

### Improvements
- Improvement 1
- Improvement 2

### Bug Fixes
- Fix 1
- Fix 2

### Breaking Changes
- None (or list them)

### Upgrade Guide
Instructions for upgrading from previous version
```

## Version Compatibility Matrix

| Module Version | Terraform Version | AzureRM Provider | Azure API Version |
|----------------|-------------------|------------------|-------------------|
| SAv1.0.x       | >= 1.3.0          | >= 3.0.0         | 2021-09-01        |

## Deprecation Policy

### Variable Deprecation
1. Mark as deprecated in current version
2. Add deprecation notice in description
3. Maintain for 2 minor versions
4. Remove in next major version

Example:
```hcl
variable "enable_logs" {
  description = "DEPRECATED: Use 'enable_diagnostic_settings' instead. Will be removed in SAv2.0.0"
  type        = bool
  default     = true
}
```

### Feature Deprecation
1. Add deprecation warning in documentation
2. Log deprecation warning when used
3. Provide migration guide
4. Remove after deprecation period

## Module Versioning in Usage

### Specific Version
```hcl
module "storage" {
  source  = "git::https://github.com/org/terraform-azurerm-storage.git?ref=SAv1.0.0"
  # ... configuration ...
}
```

### Version Constraints (Terraform Registry)
```hcl
module "storage" {
  source  = "org/storage/azurerm"
  version = "~> 1.0"
  # ... configuration ...
}
```

## Changelog Maintenance

Every version must have a changelog entry with:
- Version number and date
- Categories: Added, Changed, Deprecated, Removed, Fixed, Security
- Clear description of changes
- Migration instructions for breaking changes
- Links to relevant issues/PRs

## Testing Requirements by Version Type

### Major Version
- Full regression test suite
- Migration testing from previous major
- Performance benchmarks
- Security audit

### Minor Version
- Feature-specific tests
- Integration tests
- Example validation

### Patch Version
- Bug-specific tests
- Smoke tests
- Example validation

## Communication

### Version Announcements
- GitHub Release with detailed notes
- Update README.md badge
- Notify in team channels
- Update module registry

### Breaking Change Communication
- Announce in advance (when possible)
- Provide migration guide
- Offer transition period
- Support previous version temporarily