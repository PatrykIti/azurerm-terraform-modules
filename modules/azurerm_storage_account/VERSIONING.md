# Module Versioning Guide

This module uses **semantic-release** for fully automated version management based on conventional commits.

## Version Format

This module follows a custom semantic versioning format:

```
SAv{major}.{minor}.{patch}
```

Where:
- `SA` = Storage Account module identifier
- `v` = version prefix
- `{major}.{minor}.{patch}` = semantic version numbers (automatically determined)

### Examples:
- `SAv1.0.0` - First stable release
- `SAv1.1.0` - Minor feature addition (from `feat:` commits)
- `SAv1.0.1` - Bug fix (from `fix:` commits)
- `SAv2.0.0` - Breaking change (from `BREAKING CHANGE:` commits)

## Automated Version Determination

Version bumps are **automatically determined** by semantic-release based on commit messages:

### Major Version (Breaking Changes)
Triggered by:
- Commits with `BREAKING CHANGE:` in the footer
- Commits with `!` after the type (e.g., `feat!:`, `fix!:`)

```bash
feat(storage-account)!: change default encryption to customer-managed keys

BREAKING CHANGE: The default encryption is now customer-managed instead of Microsoft-managed.
Users must provide key_vault_key_id or set encryption.enabled = false.
```

### Minor Version (New Features)
Triggered by:
- Commits with type `feat:`

```bash
feat(storage-account): add support for NFS v3 protocol
feat(storage-account): implement lifecycle management policies
```

### Patch Version (Bug Fixes)
Triggered by:
- Commits with types: `fix:`, `perf:`, `revert:`, `refactor:`, `docs:`

```bash
fix(storage-account): correct validation for account name length
perf(storage-account): optimize tag merging logic
docs(storage-account): update README with new examples
```

### No Version (Ignored)
These commits don't trigger releases:
- `chore:`, `style:`, `test:`, `build:`, `ci:`

```bash
chore(storage-account): update .gitignore
test(storage-account): add unit tests for validation
```

## Automated Release Process

### Prerequisites
- All commits follow [Conventional Commits](https://www.conventionalcommits.org/) format
- Commits include module scope: `feat(storage-account): description`
- PR is merged to main branch

### Release Workflow

1. **Merge PR to main** with conventional commits
2. **Trigger Release Workflow** (manual via GitHub Actions)
3. **Semantic-release automatically**:
   - Analyzes commits since last release
   - Determines version bump type
   - Updates CHANGELOG.md
   - Updates module version in configs
   - Updates examples to use new version tag
   - Creates git tag (e.g., `SAv1.2.0`)
   - Publishes GitHub release
   - Commits all changes

### What Gets Updated Automatically

#### CHANGELOG.md
```markdown
## [1.2.0] - 2024-01-15

### 🚀 Features
- Add support for NFS v3 protocol (#123)
- Implement lifecycle management policies (#124)

### 🐛 Bug Fixes
- Correct validation for account name length (#125)
```

#### Examples Source References
```hcl
# Before release (development)
module "storage_account" {
  source = "../../"
}

# After release (automatically updated)
module "storage_account" {
  source = "github.com/org/repo//modules/azurerm_storage_account?ref=SAv1.2.0"
}
```

#### Module Configuration
- Version in `.github/module-config.yml`
- Any version references in documentation

## Version Compatibility Matrix

| Module Version | Terraform Version | AzureRM Provider | Azure API Version |
|----------------|-------------------|------------------|-------------------|
| SAv1.0.x       | >= 1.3.0          | 4.35.0 (pinned)  | 2023-01-01        |

**Note**: The AzureRM provider version is pinned to ensure consistent behavior across all deployments. Updates to the provider version are considered carefully and may result in a minor or major version bump depending on the changes.

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

### Direct from GitHub (Recommended)
```hcl
module "storage_account" {
  source = "github.com/yourusername/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.0.0"
  
  # Module configuration
  name                = "mystorageaccount"
  resource_group_name = azurerm_resource_group.main.name
  location           = "West Europe"
}
```

### Latest Version
```hcl
# NOT RECOMMENDED - Always pin to a specific version
module "storage_account" {
  source = "github.com/yourusername/azurerm-terraform-modules//modules/azurerm_storage_account"
}
```

### Version Selection Strategy
- **Production**: Always use specific version tags (e.g., `ref=SAv1.2.3`)
- **Development**: Can use branch references (e.g., `ref=feature/my-feature`)
- **Testing**: Can use commit SHA (e.g., `ref=a1b2c3d4`)

## Changelog Management

### Automated by Semantic-release

The CHANGELOG.md is **automatically maintained** by semantic-release:

- Follows [Keep a Changelog](https://keepachangelog.com/) format
- Groups changes by type with emojis:
  - 🚀 Features (from `feat:` commits)
  - 🐛 Bug Fixes (from `fix:` commits)
  - ⚡ Performance (from `perf:` commits)
  - 📚 Documentation (from `docs:` commits)
  - ♻️ Refactoring (from `refactor:` commits)
- Includes PR/issue numbers when referenced in commits
- Automatically adds release date

### Manual Entries

The only manual section is `[Unreleased]` during development:
```markdown
## [Unreleased]

### Added
- Work in progress features

### Fixed
- Known issues being worked on
```

This section is automatically cleared and moved to the version section during release.

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

## Best Practices for Commits

### Always Include Module Scope
```bash
# ✅ CORRECT - Will trigger release for this module
feat(storage-account): add support for immutable blobs
fix(storage-account): resolve network ACL validation issue

# ❌ WRONG - Will be ignored by this module's release
feat: add support for immutable blobs
fix: resolve network ACL validation issue
```

### Writing Good Commit Messages
```bash
# Feature with detailed description
feat(storage-account): add customer-managed key rotation

Implements automatic key rotation for CMK-encrypted storage accounts.
Supports both manual and automatic rotation policies.

Closes #156

# Breaking change with migration guide
feat(storage-account)!: restructure network_rules variable

BREAKING CHANGE: network_rules is now an object instead of a list.

Migration guide:
Before:
  network_rules = [{
    default_action = "Deny"
    ip_rules = ["10.0.0.0/24"]
  }]

After:
  network_rules = {
    default_action = "Deny"
    ip_rules = ["10.0.0.0/24"]
  }
```

## Release Automation Benefits

1. **Zero Manual Work**: No manual version decisions or tag creation
2. **Consistent Releases**: Every release follows the same process
3. **Automatic Documentation**: CHANGELOG always up-to-date
4. **Clear History**: Commit messages directly map to changelog entries
5. **Reduced Errors**: No human mistakes in versioning
6. **Faster Releases**: Release anytime by triggering the workflow