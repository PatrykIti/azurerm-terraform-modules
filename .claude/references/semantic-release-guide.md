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

### Module .releaserc.js
Each module contains `.releaserc.js` (JavaScript configuration for advanced features):
```javascript
const MODULE_NAME = 'azurerm_storage_account';
const TAG_PREFIX = 'SAv';
const COMMIT_SCOPE = 'storage-account';

module.exports = {
  branches: ['main'],
  tagFormat: `${TAG_PREFIX}\${version}`,
  
  plugins: [
    // Analyze commits - only processes commits with module scope
    ['@semantic-release/commit-analyzer', {
      preset: 'conventionalcommits',
      releaseRules: [
        {scope: COMMIT_SCOPE, breaking: true, release: 'major'},
        {scope: COMMIT_SCOPE, type: 'feat', release: 'minor'},
        {scope: COMMIT_SCOPE, type: 'fix', release: 'patch'},
        // Ignore commits without module scope
        {scope: '!'+COMMIT_SCOPE, release: false}
      ]
    }],
    
    // Generate CHANGELOG
    ['@semantic-release/changelog', {
      changelogFile: 'CHANGELOG.md'
    }],
    
    // Execute commands during release
    ['@semantic-release/exec', {
      prepareCmd: `
        # Update module version in README
        if [[ -x "../../scripts/update-module-version.sh" ]]; then
          ../../scripts/update-module-version.sh . "\${nextRelease.version}"
        fi
        
        # Update examples list
        if [[ -x "../../scripts/update-examples-list.sh" ]]; then
          ../../scripts/update-examples-list.sh .
        fi
        
        # Regenerate terraform-docs
        terraform-docs markdown table --output-file README.md .
      `
    }],
    
    // Commit changes
    ['@semantic-release/git', {
      assets: ['CHANGELOG.md', 'README.md', 'examples/**/*.tf']
    }],
    
    // Create GitHub release
    ['@semantic-release/github']
  ]
};
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
      description: 'Module directory name to release (e.g., azurerm_storage_account)'
      type: string  # Changed from choice for dynamic module support
```

### Automated Release on Push
The `release-changed-modules.yml` workflow automatically:
- Detects which modules changed in the push
- Runs releases in parallel for all changed modules
- Filters out non-code changes (README, tests, examples)

### Dynamic Module Support
Since the refactoring:
- No hardcoded module lists in workflows
- Module configuration extracted via `scripts/get-module-config.js`
- New modules automatically supported without workflow changes
- Validation ensures module exists before attempting release

### Automated Process
1. Workflow validates module exists
2. Extracts configuration using Node.js script
3. Changes to module directory
4. Runs `npx semantic-release`
5. Semantic-release:
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

1. Use `scripts/create-new-module.sh` which automatically:
   - Creates `.releaserc.js` with proper configuration
   - Sets up module structure with all required files
   - Adds terraform-docs configuration
   - Creates README with proper markers

2. Update module-specific values in `.releaserc.js`:
   - `MODULE_NAME` - module directory name
   - `TAG_PREFIX` - unique version prefix (e.g., `SAv`, `VNv`)
   - `COMMIT_SCOPE` - scope for conventional commits

3. Ensure commits use module scope:
   ```bash
   git commit -m "feat(storage-account): add new feature"
   ```

4. No workflow changes needed! The module will be automatically detected

## Troubleshooting

### No Release Generated
- Check commit has module scope
- Verify commits follow conventional format
- Ensure changes are in module path

### Wrong Version Bump
- Check for BREAKING CHANGE in commit
- Verify commit type (feat/fix)

### CHANGELOG Not Updated
- Check .releaserc.js exists
- Verify changelog plugin configured
- Ensure write permissions in workflow

### Missing @semantic-release/exec
- Error: `Cannot find module '@semantic-release/exec'`
- Solution: Add to package.json devDependencies
- This plugin is required for executing scripts during release

### Module Not Found in Workflow
- Workflow now accepts any module name as string input
- Use `scripts/get-module-config.js` to verify configuration
- Run `list-modules.yml` workflow to see all available modules

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

## Documentation Integration

### README Structure

Each module README uses a hybrid approach:
- Custom content (description, usage, examples) managed manually
- Technical documentation (inputs, outputs) generated by terraform-docs
- Dynamic content (version, examples list) updated by scripts

### Key Scripts

1. **update-module-version.sh**
   - Updates version between `<!-- BEGIN_VERSION -->` and `<!-- END_VERSION -->` markers
   - Called by semantic-release during release process
   - Handles module prefixes automatically

2. **update-examples-list.sh**
   - Scans `examples/` directory for available examples
   - Updates list between `<!-- BEGIN_EXAMPLES -->` and `<!-- END_EXAMPLES -->` markers
   - Extracts descriptions from example README files

3. **check-terraform-docs.sh**
   - Validates terraform-docs content is up to date
   - Used by PR validation workflow
   - Compares only the terraform-docs section, ignoring custom content

### Terraform-docs Configuration

Location: `scripts/templates/module-terraform-docs.yml`

Simple static configuration:
```yaml
formatter: "markdown table"
content: |-
  {{ .Header }}
  {{ .Requirements }}
  {{ .Providers }}
  {{ .Modules }}
  {{ .Resources }}
  {{ .Inputs }}
  {{ .Outputs }}

output:
  file: README.md
  mode: inject
  template: |-
    <!-- BEGIN_TF_DOCS -->
    {{ .Content }}
    <!-- END_TF_DOCS -->
```

### Release Process Updates

During semantic-release, the following happens:
1. Version is updated in README using `update-module-version.sh`
2. Examples list is refreshed using `update-examples-list.sh`
3. terraform-docs regenerates technical documentation
4. All changes are committed as part of the release

## Related Documentation

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Release Docs](https://semantic-release.gitbook.io/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Terraform-docs](https://terraform-docs.io/)