# Terraform Azure DevOps Project Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages Azure DevOps projects, settings, tags, and dashboards.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_project" {
  source = "path/to/azuredevops_project"

  name               = "ado-project-basic-example"
  description        = "Managed by Terraform"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"

  project_tags = ["terraform", "example"]
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a basic Azure DevOps project configuration with minimal settings.
- [Complete](examples/complete) - This example demonstrates a complete Azure DevOps project configuration with features, pipeline settings, tags, dashboards, and permissions.
- [Secure](examples/secure) - This example demonstrates a security-focused Azure DevOps project configuration with restrictive pipeline settings and limited features.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
<!-- This file will be automatically populated by terraform-docs -->
<!-- Do not edit manually - use terraform-docs to generate -->
<!-- END_TF_DOCS -->

## Additional Documentation

- [docs/IMPORT.md](docs/IMPORT.md) - Import existing Azure DevOps projects into the module
- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
