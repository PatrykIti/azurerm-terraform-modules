# Scripts Usage Analysis

## Summary of Script Usage in `/scripts` Directory

### ✅ USED Scripts

1. **check-terraform-docs.sh**
   - Used in: `.github/workflows/pr-validation.yml`
   - Purpose: Validates terraform-docs content is up to date
   - Referenced in documentation guides

2. **create-new-module.sh**
   - Referenced in documentation guides
   - Listed in `.claude/settings.local.json`
   - Purpose: Creates new Terraform modules with proper structure
   - References: `update-examples-list.sh` internally

3. **get-module-config.js**
   - Used in: `.github/workflows/module-release.yml`
   - Used in: `.github/workflows/list-modules.yml`
   - Purpose: Extracts module configuration for CI/CD processes

4. **security-scan.sh**
   - Used in: `.pre-commit-config.yaml` (local hook)
   - Purpose: Custom Terraform security scanning

5. **update-examples-list.sh**
   - Used in: `.github/workflows/pr-validation.yml`
   - Referenced by: `create-new-module.sh`
   - Purpose: Updates the examples list in module documentation

6. **update-module-version.sh**
   - Referenced in documentation guides
   - Referenced in: `.claude/references/semantic-release-guide.md`
   - Purpose: Updates module version in README files

7. **update-root-readme.sh**
   - Used in: `modules/azurerm_storage_account/.releaserc.js`
   - Purpose: Updates root README with module version during release

8. **validate-structure.sh**
   - Used in: `.pre-commit-config.yaml` (local hook)
   - Purpose: Validates module structure compliance

### ❌ UNUSED Scripts

1. **fix-example-docs.sh**
   - Only referenced in: `.claude/settings.local.json`
   - No active usage in workflows or hooks

2. **generate-example-terraform-docs-config.sh**
   - No references found in active configurations
   - Appears to be deprecated

3. **generate-full-example-docs-config.sh**
   - Only referenced in: `.claude/settings.local.json`
   - No active usage in workflows

4. **generate-terraform-docs-config.sh**
   - Marked as "(Deprecated)" in documentation guide
   - Only referenced in: `.claude/settings.local.json`

5. **update-example-docs.sh**
   - No references found in active configurations
   - Appears to be unused

## Recommendations

### Scripts to Remove
The following scripts appear to be unused and can be safely removed:
- `fix-example-docs.sh` - usuniety
- `generate-example-terraform-docs-config.sh` - usuniety
- `generate-full-example-docs-config.sh` - usuniety
- `generate-terraform-docs-config.sh` (already marked as deprecated) - usuniety
- `update-example-docs.sh` - usuniety

### Scripts to Keep
All other scripts are actively used in workflows, pre-commit hooks, or release processes and should be retained.

### Additional Notes
- Some scripts are referenced only in `.claude/settings.local.json` which appears to be for Claude AI assistance
- The `templates/` directory within `/scripts` should be reviewed separately for usage