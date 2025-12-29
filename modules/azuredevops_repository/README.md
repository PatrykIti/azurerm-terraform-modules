# Terraform Azure DevOps Repository Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure DevOps repository module for managing a Git repository, branches, permissions, and policies.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_repository" {
  source = "path/to/azuredevops_repository"

  project_id = "00000000-0000-0000-0000-000000000000"

  name = "example-repo"

  initialization = {
    init_type = "Clean"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates creating a Git repository with an initial README file.
- [Complete](examples/complete) - This example demonstrates creating a repository with branches, permissions, and a selection of branch/repository policies.
- [Secure](examples/secure) - This example demonstrates a repository with stricter review and status policies.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
<!-- This file will be automatically populated by terraform-docs -->
<!-- Do not edit manually - use terraform-docs to generate -->
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
