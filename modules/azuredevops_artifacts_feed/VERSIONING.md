# Module Versioning Guide

This module uses **semantic-release** for fully automated version management based on conventional commits.

## Version Format

This module follows a custom semantic versioning format:

```
ADOAFv{major}.{minor}.{patch}
```

Where:
- `ADOAF` = azuredevops_artifacts_feed module identifier
- `v` = version prefix
- `{major}.{minor}.{patch}` = semantic version numbers (automatically determined)

### Examples:
- `ADOAFv1.0.0` - First stable release
- `ADOAFv1.1.0` - Minor feature addition (from `feat:` commits)
- `ADOAFv1.0.1` - Bug fix (from `fix:` commits)
- `ADOAFv2.0.0` - Breaking change (from `BREAKING CHANGE:` commits)

## Automated Version Determination

Version bumps are **automatically determined** by semantic-release based on commit messages:

### Major Version (Breaking Changes)
Triggered by:
- Commits with `BREAKING CHANGE:` in the footer
- Commits with `!` after the type (e.g., `feat!:`, `fix!:`)

```bash
feat(azuredevops-artifacts-feed)!: change default behavior

BREAKING CHANGE: The default configuration has changed.
Users must now explicitly set...
```

### Minor Version (New Features)
Triggered by:
- Commits with type `feat:`

```bash
feat(azuredevops-artifacts-feed): add support for new Azure feature
feat(azuredevops-artifacts-feed): implement additional configuration options
```

### Patch Version (Bug Fixes)
Triggered by:
- Commits with types: `fix:`, `perf:`, `revert:`, `refactor:`, `docs:`

```bash
fix(azuredevops-artifacts-feed): correct validation for resource names
perf(azuredevops-artifacts-feed): optimize resource creation logic
docs(azuredevops-artifacts-feed): update README with new examples
```

### No Version (Ignored)
These commits don't trigger releases:
- `chore:`, `style:`, `test:`, `build:`, `ci:`

```bash
chore(azuredevops-artifacts-feed): update .gitignore
test(azuredevops-artifacts-feed): add unit tests for validation
```

## Automated Release Process

### Prerequisites
- All commits follow [Conventional Commits](https://www.conventionalcommits.org/) format
- Commits include module scope: `feat(azuredevops-artifacts-feed): description`
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
   - Creates git tag (e.g., `ADOAFv1.2.0`)
   - Publishes GitHub release
   - Commits all changes

### What Gets Updated Automatically

#### CHANGELOG.md
```markdown
## [1.2.0] - 2024-01-15

### 🚀 Features
- Add support for new Azure feature (#123)
- Implement additional configuration options (#124)

### 🐛 Bug Fixes
- Correct validation for resource names (#125)
```

#### Examples Source References
```hcl
# Before release (development)
module "azuredevops_artifacts_feed" {
  source = "../../"
}

# After release (automatically updated)
module "azuredevops_artifacts_feed" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_artifacts_feed?ref=ADOAFv1.2.0"
}
```

## Version Compatibility Matrix

| Module Version | Terraform Version | Azure DevOps Provider | Azure DevOps API Version |
|----------------|-------------------|-----------------------|---------------------------|
| ADOAFv1.0.x | >= 1.12.2 | 1.12.2 (pinned) | TBD |

**Note**: The Azure DevOps provider version is pinned to ensure consistent behavior across all deployments.

## Module Versioning in Usage

### Direct from GitHub (Recommended)
```hcl
module "azuredevops_artifacts_feed" {
  source = "git::https://github.com/yourusername/azurerm-terraform-modules//modules/azuredevops_artifacts_feed?ref=ADOAFv1.0.0"
  
  # Module configuration
  # ...
}
```

### Version Selection Strategy
- **Production**: Always use specific version tags (e.g., `ref=ADOAFv1.2.3`)
- **Development**: Can use branch references (e.g., `ref=feature/my-feature`)
- **Testing**: Can use commit SHA (e.g., `ref=a1b2c3d4`)

## Best Practices for Commits

### Always Include Module Scope
```bash
# ✅ CORRECT - Will trigger release for this module
feat(azuredevops-artifacts-feed): add new functionality
fix(azuredevops-artifacts-feed): resolve validation issue

# ❌ WRONG - Will be ignored by this module's release
feat: add new functionality
fix: resolve validation issue
```

### Writing Good Commit Messages
```bash
# Feature with detailed description
feat(azuredevops-artifacts-feed): add support for private endpoints

Implements private endpoint configuration for enhanced security.
Supports multiple endpoints per resource.

Closes #156

# Breaking change with migration guide
feat(azuredevops-artifacts-feed)!: restructure input variables

BREAKING CHANGE: The input variable structure has changed.

Migration guide:
Before:
  example_var = ["value1", "value2"]

After:
  example_var = {
    items = ["value1", "value2"]
  }
```

## Release Automation Benefits

1. **Zero Manual Work**: No manual version decisions or tag creation
2. **Consistent Releases**: Every release follows the same process
3. **Automatic Documentation**: CHANGELOG always up-to-date
4. **Clear History**: Commit messages directly map to changelog entries
5. **Reduced Errors**: No human mistakes in versioning
6. **Faster Releases**: Release anytime by triggering the workflow
