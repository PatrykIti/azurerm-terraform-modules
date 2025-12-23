# Terraform Azure DevOps Identity Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages Azure DevOps identities (groups, memberships, entitlements, and security role assignments).

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_identity" {
  source = "path/to/azuredevops_identity"

  groups = {
    platform = {
      display_name = "ADO Platform Team"
      description  = "Platform engineering group"
    }
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a minimal Azure DevOps identity configuration.
- [Complete](examples/complete) - This example demonstrates groups, memberships, and optional entitlements.
- [Secure](examples/secure) - This example demonstrates a security-focused identity configuration with explicit memberships and minimal entitlements.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
<!-- This file will be automatically populated by terraform-docs -->
<!-- Do not edit manually - use terraform-docs to generate -->
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
