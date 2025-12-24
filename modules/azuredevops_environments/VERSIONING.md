# Module Versioning Guide

This module uses **semantic-release** for fully automated version management based on conventional commits.

## Version Format

This module follows a custom semantic versioning format:

```
ADORv{major}.{minor}.{patch}
```

Where:
- `ADOR` = azuredevops_environments module identifier
- `v` = version prefix
- `{major}.{minor}.{patch}` = semantic version numbers (automatically determined)

### Examples:
- `ADORv1.0.0` - First stable release
- `ADORv1.1.0` - Minor feature addition (from `feat:` commits)
- `ADORv1.0.1` - Bug fix (from `fix:` commits)
- `ADORv2.0.0` - Breaking change (from `BREAKING CHANGE:` commits)

## Automated Version Determination

Version bumps are **automatically determined** by semantic-release based on commit messages:

### Major Version (Breaking Changes)
Triggered by:
- Commits with `BREAKING CHANGE:` in the footer
- Commits with `!` after the type (e.g., `feat!:`, `fix!:`)

```bash
feat(azuredevops-environments)!: change default behavior

BREAKING CHANGE: The default configuration has changed.
Users must now explicitly set...
```

### Minor Version (New Features)
Triggered by:
- Commits with type `feat:`

```bash
feat(azuredevops-environments): add support for new Azure feature
feat(azuredevops-environments): implement additional configuration options
```

### Patch Version (Bug Fixes)
Triggered by:
- Commits with types: `fix:`, `perf:`, `revert:`, `refactor:`, `docs:`

```bash
fix(azuredevops-environments): correct validation for resource names
perf(azuredevops-environments): optimize resource creation logic
docs(azuredevops-environments): update README with new examples
```

### No Version (Ignored)
These commits don't trigger releases:
- `chore:`, `style:`, `test:`, `build:`, `ci:`

```bash
chore(azuredevops-environments): update .gitignore
test(azuredevops-environments): add unit tests for validation
```

## Automated Release Process

### Prerequisites
- All commits follow [Conventional Commits](https://www.conventionalcommits.org/) format
- Commits include module scope: `feat(azuredevops-environments): description`
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
   - Creates git tag (e.g., `ADORv1.2.0`)
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
module "azuredevops_environments" {
  source = "../../"
}

# After release (automatically updated)
module "azuredevops_environments" {
  source = "github.com/org/repo//modules/azuredevops_environments?ref=ADORv1.2.0"
}
```

## Version Compatibility Matrix

| Module Version | Terraform Version | AzureRM Provider | Azure API Version |
|----------------|-------------------|------------------|-------------------|
| ADORv1.0.x | >= 1.3.0 | 4.36.0 (pinned) | TBD |

**Note**: The AzureRM provider version is pinned to ensure consistent behavior across all deployments.

## Module Versioning in Usage

### Direct from GitHub (Recommended)
```hcl
module "azuredevops_environments" {
  source = "github.com/yourusername/azurerm-terraform-modules//modules/azuredevops_environments?ref=ADORv1.0.0"
  
  # Module configuration
  # ...
}
```

### Version Selection Strategy
- **Production**: Always use specific version tags (e.g., `ref=ADORv1.2.3`)
- **Development**: Can use branch references (e.g., `ref=feature/my-feature`)
- **Testing**: Can use commit SHA (e.g., `ref=a1b2c3d4`)

## Best Practices for Commits

### Always Include Module Scope
```bash
# ✅ CORRECT - Will trigger release for this module
feat(azuredevops-environments): add new functionality
fix(azuredevops-environments): resolve validation issue

# ❌ WRONG - Will be ignored by this module's release
feat: add new functionality
fix: resolve validation issue
```

### Writing Good Commit Messages
```bash
# Feature with detailed description
feat(azuredevops-environments): add support for private endpoints

Implements private endpoint configuration for enhanced security.
Supports multiple endpoints per resource.

Closes #156

# Breaking change with migration guide
feat(azuredevops-environments)!: restructure input variables

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