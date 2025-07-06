# Semantic Release Integration Guide

This guide explains how semantic-release is integrated in this monorepo for automated versioning and CHANGELOG management.

## Overview

We use [semantic-release](https://semantic-release.gitbook.io/) to automate:
- Version determination based on conventional commits
- CHANGELOG generation following Keep a Changelog format
- Git tagging with module-specific prefixes
- GitHub release creation
- Automatic commit of updated files

## Why Semantic Release?

**Philosophy**: "Nothing manual in the repo" - Everything should be automated.

Instead of manually:
- Deciding version numbers
- Writing CHANGELOG entries
- Creating git tags
- Publishing releases

Semantic-release does it all based on your commit messages.

## How It Works

### 1. Commit Analysis
Semantic-release analyzes commits since the last release:
- `feat:` → Minor version bump (1.0.0 → 1.1.0)
- `fix:` → Patch version bump (1.0.0 → 1.0.1)
- `BREAKING CHANGE:` → Major version bump (1.0.0 → 2.0.0)

### 2. Module-Specific Releases
Each module has its own:
- Version sequence (e.g., SAv1.2.3 for Storage Account)
- CHANGELOG.md file
- Release configuration (.releaserc.json)
- Git tags with module prefix

### 3. Monorepo Support
- Commits are filtered by module path
- Only commits affecting a module trigger its release
- Each module releases independently

## Configuration

### Module .releaserc.json
Each module contains `.releaserc.json`:
```json
{
  "branches": ["main"],
  "tagFormat": "SAv${version}",  // Module-specific prefix
  "plugins": [
    ["@semantic-release/commit-analyzer", {
      "preset": "conventionalcommits"
    }],
    ["@semantic-release/changelog", {
      "changelogFile": "CHANGELOG.md"
    }],
    ["@semantic-release/git", {
      "assets": ["CHANGELOG.md"]
    }]
  ]
}
```

### Commit Scope Requirements
Commits MUST include module scope:
```bash
feat(storage-account): add encryption support
fix(storage-account): correct validation logic
```

## Workflow Integration

### Manual Release Trigger
```yaml
workflow_dispatch:
  inputs:
    module:
      description: 'Module to release'
      type: choice
      options:
        - azurerm_storage_account
```

### Automated Process
1. Workflow changes to module directory
2. Runs `npx semantic-release`
3. Semantic-release:
   - Analyzes commits for that module
   - Determines next version
   - Updates CHANGELOG.md
   - Creates git tag
   - Pushes changes
   - Creates GitHub release

## CHANGELOG Format

Semantic-release generates CHANGELOG following Keep a Changelog:

```markdown
## [1.2.0] - 2024-01-15

### Features
- Add encryption support (#123)

### Bug Fixes
- Correct validation logic (#124)
```

## Best Practices

### 1. Commit Messages
Always use conventional commits with module scope:
```bash
# Good
feat(storage-account): add new feature
fix(virtual-network): resolve bug

# Bad
feat: add new feature  # Missing scope!
```

### 2. Breaking Changes
Document breaking changes in commit body:
```bash
feat(storage-account): change API structure

BREAKING CHANGE: The 'enable_logs' variable is now 'diagnostic_settings'
```

### 3. Module Prefixes
Each module MUST have unique prefix:
- Storage Account: `SAv`
- Virtual Network: `VNv`
- Key Vault: `KVv`

## Adding New Modules

When creating a new module:

1. Copy `.releaserc.json` template
2. Update `tagFormat` with module prefix
3. Ensure commits use module scope
4. Add module to workflow choices

## Troubleshooting

### No Release Generated
- Check commit has module scope
- Verify commits follow conventional format
- Ensure changes are in module path

### Wrong Version Bump
- Check for BREAKING CHANGE in commit
- Verify commit type (feat/fix)

### CHANGELOG Not Updated
- Check .releaserc.json exists
- Verify changelog plugin configured
- Ensure write permissions in workflow

## Example Release Flow

1. Developer commits:
   ```bash
   git commit -m "feat(storage-account): add lifecycle policies"
   ```

2. PR merged to main

3. Release workflow triggered (manual or automated)

4. Semantic-release:
   - Finds feat commit → minor bump
   - Updates version from 1.0.0 to 1.1.0
   - Generates CHANGELOG entry
   - Creates tag `SAv1.1.0`
   - Publishes GitHub release

5. Module released with zero manual intervention!

## Terraform-docs Integration

### Automatic README Updates

Each module includes `.terraform-docs.yml` configuration that:
- Generates consistent README format across all modules
- Includes current module version
- Automatically adds links to VERSIONING.md and SECURITY.md
- Updates via the `module-docs.yml` workflow

### Configuration Template

Location: `scripts/templates/.terraform-docs.yml`

Key features:
- Injects module version dynamically
- Includes example code from `examples/simple/main.tf`
- Adds "Additional Documentation" section with links to:
  - VERSIONING.md - Module versioning and release process
  - SECURITY.md - Security features and configuration guidelines

### Workflow Integration

The `module-docs.yml` workflow:
1. Triggers on changes to Terraform files
2. Runs terraform-docs for affected modules
3. Creates PRs with documentation updates
4. Ensures README always reflects current module structure

## Related Documentation

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Release Docs](https://semantic-release.gitbook.io/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Terraform-docs](https://terraform-docs.io/)