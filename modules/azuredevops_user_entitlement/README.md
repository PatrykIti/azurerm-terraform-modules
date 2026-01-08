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

  user_entitlement = {
    key                  = "demo-user"
    principal_name       = "user@example.com"
    account_license_type = "basic"
    licensing_source     = "account"
  }
}
```

For multiple entitlements, iterate at the caller level (`for_each` on the module) and pass a single `user_entitlement` per module instance.

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - Minimal user entitlement assignment.
- [Complete](examples/complete) - Module iteration with principal and origin selectors.
- [Secure](examples/secure) - Stakeholder license example.
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
| <a name="input_user_entitlement"></a> [user\_entitlement](#input\_user\_entitlement) | User entitlement configuration. Provide either principal_name or origin+origin_id. | <pre>object({<br/>    key                  = optional(string)<br/>    principal_name       = optional(string)<br/>    origin_id            = optional(string)<br/>    origin               = optional(string)<br/>    account_license_type = optional(string, "express")<br/>    licensing_source     = optional(string, "account")<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_user_entitlement_descriptor"></a> [user\_entitlement\_descriptor](#output\_user\_entitlement\_descriptor) | The descriptor of the Azure DevOps user entitlement managed by the module. |
| <a name="output_user_entitlement_id"></a> [user\_entitlement\_id](#output\_user\_entitlement\_id) | The ID of the Azure DevOps user entitlement managed by the module. |
| <a name="output_user_entitlement_key"></a> [user\_entitlement\_key](#output\_user\_entitlement\_key) | Derived key for the entitlement (key, principal_name, or origin_id). |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
