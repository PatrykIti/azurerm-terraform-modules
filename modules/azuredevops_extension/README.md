# Terraform Azure DevOps Extension Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure DevOps extension module for managing a single Marketplace extension.
Use module-level `for_each` to install multiple extensions.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_extension" {
  source = "path/to/azuredevops_extension"

  publisher_id      = "publisher-id"
  extension_id      = "extension-id"
  extension_version = "1.2.3"
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates installing a single Azure DevOps Marketplace extension.
- [Complete](examples/complete) - This example demonstrates installing multiple Azure DevOps Marketplace extensions with version pinning using module-level `for_each`.
- [Secure](examples/secure) - This example demonstrates installing only approved Azure DevOps Marketplace extensions using an allowlist and module-level `for_each`.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
<!-- This file will be automatically populated by terraform-docs -->
<!-- Do not edit manually - use terraform-docs to generate -->
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing Azure DevOps extensions into the module
