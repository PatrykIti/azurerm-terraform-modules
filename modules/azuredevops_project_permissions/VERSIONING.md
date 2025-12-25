# Module Versioning

This module follows Semantic Versioning (SemVer) using the repository's `semantic-release` pipeline.

## Version Format

`ADOPPv{major}.{minor}.{patch}`

- `ADOPP` = azuredevops_project_permissions module identifier
- `major` = breaking changes
- `minor` = new features, backward compatible
- `patch` = bug fixes and docs

## Examples

- `ADOPPv1.0.0` - First stable release
- `ADOPPv1.1.0` - Minor feature addition (from `feat:` commits)
- `ADOPPv1.0.1` - Bug fix (from `fix:` commits)
- `ADOPPv2.0.0` - Breaking change (from `BREAKING CHANGE:` commits)

## Automated Version Determination

`semantic-release` uses commit messages to determine the next version:

- `feat(azuredevops-project-permissions): ...` → minor bump
- `fix(azuredevops-project-permissions): ...` → patch bump
- `BREAKING CHANGE:` → major bump

## Automated Release Process

On merge to `main`, the release workflow:

1. Runs tests and validation
2. Determines version based on commits
3. Creates git tag (e.g., `ADOPPv1.2.0`)
4. Publishes release notes

## How to Use Module Versions

Reference a specific version tag in Terraform:

```hcl
module "azuredevops_project_permissions" {
  source = "github.com/yourusername/azurerm-terraform-modules//modules/azuredevops_project_permissions?ref=ADOPPv1.0.0"
}
```

## Compatibility

| Module Version | Terraform Version | Azure DevOps Provider |
|---------------|-------------------|-----------------------|
| ADOPPv1.0.x   | >= 1.12.2         | 1.12.2                |

## Best Practices

- Always use a fixed `ref=` in production.
- Use `feat`/`fix` scopes matching the module's `commit_scope`.
