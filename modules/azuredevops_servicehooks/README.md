# Terraform Azure DevOps Service Hooks Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure DevOps service hooks module for managing webhook and storage queue subscriptions with permissions.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_servicehooks" {
  source = "path/to/azuredevops_servicehooks"

  project_id = "00000000-0000-0000-0000-000000000000"

  webhooks = [
    {
      url = "https://example.com/webhook"
      git_push = {}
    }
  ]
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates creating a simple webhook service hook.
- [Complete](examples/complete) - This example demonstrates webhooks and storage queue hooks with pipeline filters.
- [Secure](examples/secure) - This example demonstrates a filtered webhook with restricted permissions.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
<!-- This file will be automatically populated by terraform-docs -->
<!-- Do not edit manually - use terraform-docs to generate -->
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
