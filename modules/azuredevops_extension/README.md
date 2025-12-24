# Terraform Azure DevOps Extension Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure DevOps extensions module for managing Marketplace extensions.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_extension" {
  source = "path/to/azuredevops_extension"

  extensions = [
    {
      publisher_id = "publisher-id"
      extension_id = "extension-id"
    }
  ]
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates installing a single Azure DevOps Marketplace extension.
- [Complete](examples/complete) - This example demonstrates installing multiple Azure DevOps Marketplace extensions with version pinning.
- [Secure](examples/secure) - This example demonstrates installing only approved Azure DevOps Marketplace extensions using an allowlist.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
<!-- This file will be automatically populated by terraform-docs -->
<!-- Do not edit manually - use terraform-docs to generate -->
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
