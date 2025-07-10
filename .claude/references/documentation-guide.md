# Documentation Guide

This guide explains how documentation is managed in the Azure Terraform Modules repository.

## Overview

The repository uses a hybrid approach for documentation:
- **terraform-docs** generates technical documentation (inputs, outputs, resources, etc.)
- Custom scripts manage dynamic content (examples list, version numbers)
- Static content provides module descriptions and usage examples

## Documentation Structure

Each module's README.md contains:

```markdown
# Terraform Azure MODULE_NAME Module

## Module Version
<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description
[Custom description of the module]

## Usage
[Basic usage example]

## Examples
<!-- BEGIN_EXAMPLES -->
<!-- Examples list will be auto-generated here -->
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
<!-- Technical documentation will be auto-generated here -->
<!-- END_TF_DOCS -->

## Additional Documentation
- Links to VERSIONING.md, SECURITY.md, etc.
```

## Key Components

### 1. terraform-docs Configuration

Each module has a static `.terraform-docs.yml` file:

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

### 2. Examples List Management

The `scripts/update-examples-list.sh` script:
- Scans the `examples/` directory
- Extracts descriptions from example README files
- Updates content between `<!-- BEGIN_EXAMPLES -->` and `<!-- END_EXAMPLES -->`

Usage:
```bash
./scripts/update-examples-list.sh modules/azurerm_storage_account
```

### 3. Version Management

The `scripts/update-module-version.sh` script:
- Updates version between `<!-- BEGIN_VERSION -->` and `<!-- END_VERSION -->`
- Called by semantic-release during the release process
- Handles module prefixes (e.g., `SAv1.0.0` for storage account)

Usage:
```bash
./scripts/update-module-version.sh modules/azurerm_storage_account "1.0.0"
```

### 4. Documentation Validation

The `scripts/check-terraform-docs.sh` script:
- Extracts terraform-docs content from README
- Compares with freshly generated content
- Used by PR validation workflow

Usage:
```bash
./scripts/check-terraform-docs.sh modules/azurerm_storage_account
```

## Workflow Integration

### PR Validation

The PR validation workflow:
1. Updates examples list using `update-examples-list.sh`
2. Checks if terraform-docs is up to date using `check-terraform-docs.sh`
3. Reports any outdated documentation

### Semantic Release

During release, semantic-release:
1. Updates module version using `update-module-version.sh`
2. Updates examples list using `update-examples-list.sh`
3. Regenerates terraform-docs
4. Commits all changes

## Common Tasks

### Creating a New Module

1. Use `scripts/create-new-module.sh` which automatically:
   - Creates README with proper markers
   - Adds static terraform-docs configuration
   - Sets up example structure

2. Generate initial documentation:
   ```bash
   cd modules/your_module
   terraform-docs markdown table --output-file README.md .
   ./scripts/update-examples-list.sh .
   ```

### Adding a New Example

1. Create example directory:
   ```bash
   mkdir -p modules/your_module/examples/new-example
   ```

2. Add example files with descriptive README

3. Update examples list:
   ```bash
   ./scripts/update-examples-list.sh modules/your_module
   ```

### Updating Documentation

After making changes to variables, outputs, or resources:

```bash
cd modules/your_module
terraform-docs markdown table --output-file README.md .
```

## Templates

### Module README Template

Located at `scripts/templates/README.md`:
- Contains all required markers
- Placeholder content
- Standard structure

### Example README Template

Example READMEs should include:
- Clear description as the first paragraph
- Usage instructions
- terraform-docs markers for technical details

## Best Practices

1. **Always use markers**: Never remove BEGIN/END markers from README files

2. **Keep descriptions updated**: Update module descriptions when functionality changes

3. **Document examples**: Each example should have a clear, descriptive README

4. **Commit generated content**: Always commit documentation updates with your changes

5. **Version consistency**: Let semantic-release handle version updates

## Troubleshooting

### "Documentation is outdated" in PR

Run these commands:
```bash
cd modules/affected_module
./scripts/update-examples-list.sh .
terraform-docs markdown table --output-file README.md .
git add README.md
git commit -m "docs: update module documentation"
```

### Examples not showing up

1. Ensure example has a `main.tf` file
2. Check example README has a description
3. Run `update-examples-list.sh`

### Version not updating

- Check BEGIN_VERSION/END_VERSION markers exist
- Ensure semantic-release configuration includes version update script
- Verify module has `.releaserc.js` file

## Scripts Reference

| Script | Purpose | Usage |
|--------|---------|-------|
| `update-examples-list.sh` | Update examples list in README | `./script modules/module_name` |
| `update-module-version.sh` | Update version in README | `./script modules/module_name "1.0.0"` |
| `check-terraform-docs.sh` | Validate terraform-docs content | `./script modules/module_name` |
| `generate-terraform-docs-config.sh` | (Deprecated) Generate dynamic config | Not used anymore |