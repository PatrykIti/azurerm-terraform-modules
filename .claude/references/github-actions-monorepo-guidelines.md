# GitHub Actions Monorepo Guidelines for Terraform Modules

## Overview

This document provides guidelines for organizing GitHub Actions workflows in a Terraform modules monorepo. The approach addresses GitHub's constraint that workflows must be in `.github/workflows/` while maintaining logical separation for dozens of modules.

## Architecture: Dynamic Discovery with Composite Actions

### Key Principles

1. **Single Dispatcher Pattern**: One main workflow that dynamically discovers and runs module-specific CI/CD
2. **Composite Actions per Module**: Module-specific logic lives with the module as composite actions
3. **Path Filtering**: Only run CI/CD for changed modules
4. **Configuration as Code**: Module-specific settings in configuration files

### Directory Structure

```
azurerm-terraform-modules/
├── .github/
│   ├── workflows/
│   │   ├── module-ci.yml              # Main CI dispatcher workflow
│   │   ├── module-release.yml         # Release workflow with dynamic matrix
│   │   ├── module-docs.yml            # Documentation generation workflow
│   │   ├── repo-maintenance.yml       # Repository-wide maintenance tasks
│   │   └── _reusable-*.yml           # Shared reusable workflows (prefixed with _)
│   └── actions/
│       ├── detect-modules/            # Custom action for module detection
│       │   └── action.yml
│       └── terraform-setup/           # Shared Terraform setup action
│           └── action.yml
├── modules/
│   ├── storage_account/
│   │   ├── .github/
│   │   │   ├── actions/
│   │   │   │   ├── validate/         # Module-specific validation
│   │   │   │   │   └── action.yml
│   │   │   │   ├── test/            # Module-specific testing
│   │   │   │   │   └── action.yml
│   │   │   │   └── release/         # Module-specific release logic
│   │   │   │       └── action.yml
│   │   │   └── module-config.yml    # Module metadata and CI configuration
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── virtual_network/
│       └── [similar structure]
└── shared/
    └── terraform-lib/                # Shared Terraform utilities
```

## Implementation Details

### 1. Main CI Dispatcher Workflow

**File**: `.github/workflows/module-ci.yml`

```yaml
name: Module CI

on:
  pull_request:
    paths:
      - 'modules/**'
      - 'shared/**'
  push:
    branches:
      - main
      - 'release/**'
    paths:
      - 'modules/**'
      - 'shared/**'

jobs:
  detect-changes:
    runs-on: ubuntu-latest
    outputs:
      modules: ${{ steps.filter.outputs.changes }}
      matrix: ${{ steps.set-matrix.outputs.matrix }}
    steps:
      - uses: actions/checkout@v5
      
      - uses: dorny/paths-filter@v3
        id: filter
        with:
          filters: |
            storage_account:
              - 'modules/storage_account/**'
              - 'shared/**'
            virtual_network:
              - 'modules/virtual_network/**'
              - 'shared/**'
            key_vault:
              - 'modules/key_vault/**'
              - 'shared/**'
      
      - id: set-matrix
        run: |
          MODULES='${{ steps.filter.outputs.changes }}'
          echo "matrix={\"module\":${MODULES}}" >> $GITHUB_OUTPUT

  validate:
    needs: detect-changes
    if: ${{ needs.detect-changes.outputs.modules != '[]' }}
    runs-on: ubuntu-latest
    strategy:
      matrix: ${{ fromJson(needs.detect-changes.outputs.matrix) }}
      fail-fast: false
    steps:
      - uses: actions/checkout@v5
      
      - name: Setup Terraform
        uses: ./.github/actions/terraform-setup
        
      - name: Validate Module ${{ matrix.module }}
        uses: ./modules/${{ matrix.module }}/.github/actions/validate
        with:
          terraform-version: ${{ vars.TERRAFORM_VERSION }}

  test:
    needs: [detect-changes, validate]
    if: ${{ needs.detect-changes.outputs.modules != '[]' }}
    runs-on: ubuntu-latest
    strategy:
      matrix: ${{ fromJson(needs.detect-changes.outputs.matrix) }}
      fail-fast: false
    steps:
      - uses: actions/checkout@v5
      
      - name: Test Module ${{ matrix.module }}
        uses: ./modules/${{ matrix.module }}/.github/actions/test
        with:
          azure-credentials: ${{ secrets.AZURE_CREDENTIALS }}
```

### 2. Module-Specific Composite Action

**File**: `modules/storage_account/.github/actions/validate/action.yml`

```yaml
name: 'Validate Storage Account Module'
description: 'Validates the Azure Storage Account Terraform module'

inputs:
  terraform-version:
    description: 'Terraform version to use'
    required: true
    default: '1.5.0'

runs:
  using: 'composite'
  steps:
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ inputs.terraform-version }}
    
    - name: Terraform Format Check
      shell: bash
      working-directory: ./modules/storage_account
      run: |
        terraform fmt -check -recursive
        
    - name: Terraform Init
      shell: bash
      working-directory: ./modules/storage_account
      run: |
        terraform init -backend=false
        
    - name: Terraform Validate
      shell: bash
      working-directory: ./modules/storage_account
      run: |
        terraform validate
        
    - name: TFLint
      shell: bash
      working-directory: ./modules/storage_account
      run: |
        curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
        tflint --init
        tflint
        
    - name: Checkov Security Scan
      shell: bash
      working-directory: ./modules/storage_account
      run: |
        pip3 install checkov
        checkov -d . --framework terraform --quiet --compact
```

### 3. Module Configuration File

**File**: `modules/storage_account/.github/module-config.yml`

```yaml
name: storage_account
description: "Azure Storage Account Terraform module"
version: 1.0.0
terraform:
  required_version: ">= 1.5.0"
  required_providers:
    azurerm: ">= 3.0.0"
dependencies:
  - shared/terraform-lib
ci:
  test_regions:
    - westeurope
    - northeurope
  test_scenarios:
    - basic
    - advanced-security
    - private-endpoint
release:
  versioning: semver
  changelog: keep-a-changelog
  tag_prefix: "storage_account/v"
```

### 4. Custom Module Detection Action

**File**: `.github/actions/detect-modules/action.yml`

```yaml
name: 'Detect Terraform Modules'
description: 'Automatically detects all Terraform modules in the repository'

outputs:
  modules:
    description: 'JSON array of detected module names'
    value: ${{ steps.detect.outputs.modules }}
  filters:
    description: 'Path filters for dorny/paths-filter'
    value: ${{ steps.detect.outputs.filters }}

runs:
  using: 'composite'
  steps:
    - id: detect
      shell: bash
      run: |
        # Find all directories containing main.tf in modules/
        MODULES=$(find modules -name "main.tf" -type f | \
                  sed 's|/main.tf||' | \
                  sed 's|modules/||' | \
                  sort)
        
        # Create JSON array
        JSON_ARRAY=$(echo "$MODULES" | jq -R -s -c 'split("\n")[:-1]')
        echo "modules=$JSON_ARRAY" >> $GITHUB_OUTPUT
        
        # Create path filters
        FILTERS=""
        for module in $MODULES; do
          FILTERS="${FILTERS}${module}:\n  - 'modules/${module}/**'\n  - 'shared/**'\n"
        done
        echo "filters<<EOF" >> $GITHUB_OUTPUT
        echo -e "$FILTERS" >> $GITHUB_OUTPUT
        echo "EOF" >> $GITHUB_OUTPUT
```

## Advanced Patterns

### 1. Release Workflow with Versioning

**File**: `.github/workflows/module-release.yml`

```yaml
name: Module Release

on:
  workflow_dispatch:
    inputs:
      module:
        description: 'Module to release'
        required: true
        type: choice
        options:
          - storage_account
          - virtual_network
          - key_vault
      version:
        description: 'Version to release (e.g., 1.2.0)'
        required: true

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
      
      - name: Release Module
        uses: ./modules/${{ inputs.module }}/.github/actions/release
        with:
          version: ${{ inputs.version }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

### 2. Dependency Management

For modules with interdependencies, use job dependencies and artifact sharing:

```yaml
jobs:
  build-shared:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
      - name: Build shared components
        run: |
          # Build shared terraform utilities
      - uses: actions/upload-artifact@v4
        with:
          name: shared-artifacts
          path: shared/

  test-modules:
    needs: build-shared
    strategy:
      matrix:
        module: ${{ fromJson(needs.detect-changes.outputs.modules) }}
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: shared-artifacts
          path: shared/
```

## Best Practices

### 1. Module Organization

- **Composite Actions**: Keep them focused on a single responsibility (validate, test, release)
- **Configuration**: Use `module-config.yml` for module metadata, not hardcoded values
- **Naming**: Use consistent naming patterns for actions and workflows

### 2. Performance Optimization

```yaml
# Cache Terraform providers and modules
- name: Cache Terraform
  uses: actions/cache@v4
  with:
    path: |
      ~/.terraform.d/plugin-cache
      **/.terraform/providers
    key: terraform-${{ runner.os }}-${{ hashFiles('**/.terraform.lock.hcl') }}
```

### 3. Security

```yaml
# Use OIDC for Azure authentication
- name: Azure Login
  uses: azure/login@v2
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

## Trade-offs and Considerations

### Advantages

1. **Scalability**: Adding new modules requires minimal changes to root workflows
2. **Maintainability**: Module teams own their CI/CD logic
3. **Performance**: Only affected modules are tested
4. **Flexibility**: Each module can have custom CI/CD steps

### Limitations

1. **GitHub UI**: All workflows appear in root, but are logically organized
2. **Composite Action Constraints**: Cannot use `if:` conditions on steps or call reusable workflows
3. **Complex Dependencies**: Requires explicit job dependencies for inter-module relationships

### Migration Path

1. Start with 1-2 pilot modules
2. Implement basic validation composite actions
3. Add dynamic discovery gradually
4. Migrate existing workflows incrementally

## Troubleshooting

### Common Issues

1. **Path filters not triggering**: Ensure shared dependencies are included in filters
2. **Composite action not found**: Check the path and that `action.yml` exists
3. **Matrix expansion limits**: GitHub has a limit of 256 jobs per workflow

### Debugging

```yaml
# Add debug output to composite actions
- name: Debug Info
  shell: bash
  run: |
    echo "Module: ${{ inputs.module }}"
    echo "Working Directory: $(pwd)"
    echo "Files: $(ls -la)"
```

## References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Composite Actions Guide](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action)
- [Reusable Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [dorny/paths-filter](https://github.com/dorny/paths-filter)