# Terraform Azure DevOps Group Entitlement Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **1.0.0**
<!-- END_VERSION -->

## Description

Manages a single Azure DevOps `azuredevops_group_entitlement` resource.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_group_entitlement" {
  source = "path/to/azuredevops_group_entitlement"

  group_entitlement = {
    key                  = "platform-group"
    display_name         = "ADO Platform Team"
    account_license_type = "basic"
    licensing_source     = "account"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example creates one group entitlement selected by `display_name`.
- [Complete](examples/complete) - This example creates one entitlement using the `origin+origin_id` selector mode.
- [Secure](examples/secure) - This example applies a minimal-privilege entitlement profile using `stakeholder` license.
<!-- END_EXAMPLES -->

## Module Documentation

- [docs/README.md](docs/README.md) - Module-specific documentation overview
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing group entitlement into the module

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
| [azuredevops_group_entitlement.group_entitlement](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/group_entitlement) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_group_entitlement"></a> [group\_entitlement](#input\_group\_entitlement) | Group entitlement configuration. Provide either display\_name or origin+origin\_id. | <pre>object({<br/>    key                  = optional(string)<br/>    display_name         = optional(string)<br/>    origin_id            = optional(string)<br/>    origin               = optional(string)<br/>    account_license_type = optional(string, "express")<br/>    licensing_source     = optional(string, "account")<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_group_entitlement_descriptor"></a> [group\_entitlement\_descriptor](#output\_group\_entitlement\_descriptor) | The descriptor of the Azure DevOps group entitlement managed by the module. |
| <a name="output_group_entitlement_id"></a> [group\_entitlement\_id](#output\_group\_entitlement\_id) | The ID of the Azure DevOps group entitlement managed by the module. |
| <a name="output_group_entitlement_key"></a> [group\_entitlement\_key](#output\_group\_entitlement\_key) | Derived key for the entitlement (key, display\_name, or origin\_id). |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
