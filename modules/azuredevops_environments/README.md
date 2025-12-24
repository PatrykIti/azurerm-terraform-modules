# Terraform Azure DevOps Environments Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure DevOps environments module for managing environments, resources, and checks.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_environments" {
  source = "path/to/azuredevops_environments"

  project_id = "00000000-0000-0000-0000-000000000000"

  environments = {
    dev = {
      description = "Development environment"
    }
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates creating a basic Azure DevOps environment.
- [Complete](examples/complete) - This example demonstrates an environment with a Kubernetes resource and approval checks.
- [Secure](examples/secure) - This example demonstrates environment approvals and exclusive locks.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
<!-- This file will be automatically populated by terraform-docs -->
<!-- Do not edit manually - use terraform-docs to generate -->
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
