# Module Versioning Guide

This module uses semantic-release and conventional commits.

## Tag Format

```
ADOEv{major}.{minor}.{patch}
```

Examples:
- `ADOEv1.0.0`
- `ADOEv1.1.0`
- `ADOEv2.0.0`

## Version Bump Rules

- `feat(...)` -> minor
- `fix(...)`, `perf(...)`, `refactor(...)`, `docs(...)` -> patch
- `!` or `BREAKING CHANGE:` -> major

## Release Behavior

On release, automation:
- updates `CHANGELOG.md`
- creates git tag with module prefix
- updates example source references from local paths to tagged git source

## Commit Scope

Use module scope in commit messages:

```text
feat(azuredevops-environments): add nested kubernetes checks
fix(azuredevops-environments): tighten check name validation
```

## Compatibility Matrix

| Module Version | Terraform | Azure DevOps Provider |
|---|---|---|
| `ADOEv1.x` | `>= 1.12.2` | `1.12.2` |

The module is Azure DevOps-provider based (`microsoft/azuredevops`) and does not use AzureRM.
