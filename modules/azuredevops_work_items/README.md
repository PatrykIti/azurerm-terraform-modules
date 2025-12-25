# Terraform Azure DevOps Work Items Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure DevOps work items module for managing processes, work items, queries, and permissions.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_work_items" {
  source = "path/to/azuredevops_work_items"

  project_id = "00000000-0000-0000-0000-000000000000"

  processes = {
    custom = {
      name                   = "custom_agile"
      parent_process_type_id = "adcc42ab-9882-485e-a3ed-7678f01f66bc"
    }
  }

  work_items = [
    {
      title = "Example Work Item"
      type  = "Issue"
      state = "Active"
    }
  ]
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates creating a simple work item.
- [Complete](examples/complete) - This example demonstrates processes, queries, permissions, and work items.
- [Secure](examples/secure) - This example demonstrates restricted permissions for work item areas, iterations, and tagging.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
<!-- This file will be automatically populated by terraform-docs -->
<!-- Do not edit manually - use terraform-docs to generate -->
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
