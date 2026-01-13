# Terraform Azure DevOps Service Principal Entitlement Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **1.0.0**
<!-- END_VERSION -->

## Description

Manages a single Azure DevOps service principal entitlement. Iterate in the consuming configuration if you need multiple entitlements.
This module is organization-scoped and does not require a project ID.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_service_principal_entitlement" {
  source = "path/to/azuredevops_service_principal_entitlement"

  origin_id            = "00000000-0000-0000-0000-000000000000"
  account_license_type = "basic"
  licensing_source     = "account"
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example assigns a single entitlement to an Azure DevOps service principal.
- [Complete](examples/complete) - This example assigns a service principal entitlement with explicit license settings.
- [Secure](examples/secure) - This example assigns a stakeholder license to a service principal.
<!-- END_EXAMPLES -->

## Module Documentation

- [docs/README.md](docs/README.md) - Module-specific documentation overview
- [docs/IMPORT.md](docs/IMPORT.md) - Import an existing Azure DevOps service principal entitlement into the module

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
| [azuredevops_service_principal_entitlement.service_principal_entitlement](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/service_principal_entitlement) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_license_type"></a> [account\_license\_type](#input\_account\_license\_type) | License type to assign to the service principal. | `string` | `"express"` | no |
| <a name="input_licensing_source"></a> [licensing\_source](#input\_licensing\_source) | Licensing source for the service principal entitlement. | `string` | `"account"` | no |
| <a name="input_origin"></a> [origin](#input\_origin) | Origin for the service principal. Only "aad" is supported. | `string` | `"aad"` | no |
| <a name="input_origin_id"></a> [origin\_id](#input\_origin\_id) | Service principal object ID used to create the entitlement. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_principal_entitlement_descriptor"></a> [service\_principal\_entitlement\_descriptor](#output\_service\_principal\_entitlement\_descriptor) | The descriptor of the service principal entitlement. |
| <a name="output_service_principal_entitlement_id"></a> [service\_principal\_entitlement\_id](#output\_service\_principal\_entitlement\_id) | The ID of the service principal entitlement. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
