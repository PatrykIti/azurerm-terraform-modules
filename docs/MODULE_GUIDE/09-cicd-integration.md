# 9. CI/CD Integration

Once a module is developed, it must be integrated into the repository's CI/CD workflows. This ensures that every change is automatically validated, tested, and that new versions can be released automatically.

## Overview of CI/CD Workflows

- **`pr-validation.yml`**: Runs on every pull request. It performs static analysis, validation, and runs short tests to provide quick feedback.
- **`module-ci.yml`**: Runs on pushes to `main`. It executes the full test suite (including integration tests) for all modules.
- **`module-release.yml`**: A manually triggered workflow that runs `semantic-release` to publish a new version of a specific module.

## Steps for Integration

The `module-ci.yml` workflow is fully dynamic and automatically discovers all modules within the `modules/` directory using a dedicated `detect-modules` action. This means **you no longer need to manually add your new module to a list or matrix in the workflow file.**

The primary integration steps are now focused on configuring the release process and providing optional CI overrides.

### Step 1: Configure Release Process

The release process is handled by `semantic-release`. The configuration is managed by two key files within your module's directory:

1.  **`module.json`**: Ensure this file is created and contains the correct `commit_scope` and `tag_prefix`. The release workflow uses this file to identify which commits belong to your module.
    
    **Example (`modules/azurerm_new_module/module.json`):**
    ```json
    {
      "name": "azurerm_new_module",
      "title": "New Module",
      "commit_scope": "new-module",
      "tag_prefix": "NMv",
      "description": "A description of the new module."
    }
    ```

2.  **`.releaserc.js`**: This file should be copied from a reference module like `azurerm_kubernetes_cluster`. It is designed to be dynamic and reads its configuration from `module.json`, so you typically don't need to modify it.

### Step 2: Verify CI/CD Integration

The CI/CD pipeline will automatically detect your module based on:
- The presence of the module directory in `modules/`
- The `module.json` file for release configuration
- Standard Terraform module structure (main.tf, variables.tf, outputs.tf)

No additional configuration is needed for standard modules. The workflows will:
- Automatically detect changes to your module
- Run validation and linting
- Execute unit tests
- Run integration tests if configured
- Generate documentation

## The Release Process

Once your module is merged into `main` and you have followed the integration steps:

1.  Ensure your commits follow the **Conventional Commits** specification with the correct scope (e.g., `feat(new-module): add feature X`).
2.  A maintainer will trigger the `module-release.yml` workflow, selecting your module from a dropdown list.
3.  The workflow will execute `semantic-release`, which will:
    - Analyze the relevant commits.
    - Determine the next version number.
    - Generate a `CHANGELOG.md`.
    - Create a new git tag (e.g., `NMv1.1.0`).
    - Push the changes and the tag to the repository.
    - Create a GitHub Release with release notes.
