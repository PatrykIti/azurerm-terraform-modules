# Terraform Azure DevOps Artifacts Feed Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure DevOps artifacts feed module for managing feeds, retention policies, and permissions.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_artifacts_feed" {
  source = "path/to/azuredevops_artifacts_feed"

  feeds = {
    project = {
      name       = "example-feed"
      project_id = "00000000-0000-0000-0000-000000000000"
    }
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates creating a project-scoped feed.
- [Complete](examples/complete) - This example demonstrates a project feed with permissions and retention policies.
- [Secure](examples/secure) - This example demonstrates a restricted feed with reader permissions and retention controls.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
<!-- This file will be automatically populated by terraform-docs -->
<!-- Do not edit manually - use terraform-docs to generate -->
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
