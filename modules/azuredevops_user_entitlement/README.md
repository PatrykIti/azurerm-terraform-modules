# Terraform Azure DevOps User Entitlement Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **0.1.0**
<!-- END_VERSION -->

## Description

Manages Azure DevOps user entitlements.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_user_entitlement" {
  source = "path/to/azuredevops_user_entitlement"

  user_entitlements = [
    {
      key                  = "demo-user"
      principal_name       = "user@example.com"
      account_license_type = "basic"
      licensing_source     = "account"
    }
  ]
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - Minimal user entitlement assignment.
- [Complete](examples/complete) - Two user entitlements with explicit keys.
- [Secure](examples/secure) - Example with stakeholder license for a user.
<!-- END_EXAMPLES -->

## Module Documentation

- [docs/README.md](docs/README.md) - Module-specific documentation overview
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing Azure DevOps user entitlements into the module

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | 1.12.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuredevops"></a> [azuredevops](#provider\_azuredevops) | 1.12.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuredevops_user_entitlement.user_entitlement](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/user_entitlement) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_user_entitlements"></a> [user\_entitlements](#input\_user\_entitlements) | List of user entitlements to manage. | <pre>list(object({<br/>    key                  = optional(string)<br/>    principal_name       = optional(string)<br/>    origin_id            = optional(string)<br/>    origin               = optional(string)<br/>    account_license_type = optional(string, "express")<br/>    licensing_source     = optional(string, "account")<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_user_entitlement_descriptors"></a> [user\_entitlement\_descriptors](#output\_user\_entitlement\_descriptors) | Map of user entitlement descriptors keyed by entitlement key. |
| <a name="output_user_entitlement_ids"></a> [user\_entitlement\_ids](#output\_user\_entitlement\_ids) | Map of user entitlement IDs keyed by entitlement key. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
