# Terraform Azure DevOps Variable Groups Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure DevOps variable groups module for managing variables and library permissions.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_variable_groups" {
  source = "path/to/azuredevops_variable_groups"

  project_id = "00000000-0000-0000-0000-000000000000"

  variable_groups = {
    shared = {
      name         = "shared-vars"
      description  = "Shared variables"
      allow_access = true
      variables = [
        {
          name  = "environment"
          value = "dev"
        }
      ]
    }
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates creating a single variable group with plain variables.
- [Complete](examples/complete) - This example demonstrates multiple variable groups with permissions and library permissions.
- [Secure](examples/secure) - This example demonstrates a restricted variable group with secret values and minimal permissions.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
<!-- This file will be automatically populated by terraform-docs -->
<!-- Do not edit manually - use terraform-docs to generate -->
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
