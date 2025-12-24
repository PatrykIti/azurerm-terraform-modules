# Terraform Azure DevOps Pipelines Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure DevOps pipelines module for managing build definitions, folders, permissions, and authorizations.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_pipelines" {
  source = "path/to/azuredevops_pipelines"

  project_id = "00000000-0000-0000-0000-000000000000"

  build_definitions = {
    example = {
      name = "example-pipeline"
      repository = {
        repo_type = "TfsGit"
        repo_id   = "00000000-0000-0000-0000-000000000000"
        yml_path  = "azure-pipelines.yml"
      }
    }
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates creating a basic YAML pipeline backed by a Git repository.
- [Complete](examples/complete) - This example demonstrates creating multiple YAML pipelines with folders and authorizations.
- [Secure](examples/secure) - This example demonstrates a pipeline with restricted permissions and explicit authorizations.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
<!-- This file will be automatically populated by terraform-docs -->
<!-- Do not edit manually - use terraform-docs to generate -->
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
