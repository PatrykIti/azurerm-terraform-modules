# Terraform Azure DevOps Team Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure DevOps team module for managing teams, members, and administrators.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_team" {
  source = "path/to/azuredevops_team"

  project_id = "00000000-0000-0000-0000-000000000000"

  teams = {
    core = {
      name        = "ado-core-team"
      description = "Core delivery team"
    }
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a minimal Azure DevOps team configuration.
- [Complete](examples/complete) - This example demonstrates multiple teams with memberships and administrators.
- [Secure](examples/secure) - This example demonstrates a security-focused team configuration.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
<!-- This file will be automatically populated by terraform-docs -->
<!-- Do not edit manually - use terraform-docs to generate -->
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
