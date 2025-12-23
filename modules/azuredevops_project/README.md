# Terraform Azure DevOps Project Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages Azure DevOps projects, settings, tags, dashboards, and permissions.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_project" {
  source = "path/to/azuredevops_project"

  project = {
    name               = "ado-project-basic-example"
    description        = "Managed by Terraform"
    visibility         = "private"
    version_control    = "Git"
    work_item_template = "Agile"
  }

  project_tags = ["terraform", "example"]
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
<!-- Examples list will be auto-generated here -->
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
<!-- This file will be automatically populated by terraform-docs -->
<!-- Do not edit manually - use terraform-docs to generate -->
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
