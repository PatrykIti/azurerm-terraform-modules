# Terraform Azure DevOps Service Principal Entitlement Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **0.1.0**
<!-- END_VERSION -->

## Description

Manages Azure DevOps service principal entitlements.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_service_principal_entitlement" {
  source = "path/to/azuredevops_service_principal_entitlement"

  service_principal_entitlements = [
    {
      key                  = "demo-sp"
      origin_id            = "00000000-0000-0000-0000-000000000000"
      account_license_type = "basic"
      licensing_source     = "account"
    }
  ]
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - Minimal service principal entitlement assignment.
- [Complete](examples/complete) - Service principal entitlement with explicit key.
- [Secure](examples/secure) - Example with stakeholder license.
<!-- END_EXAMPLES -->

## Module Documentation

- [docs/README.md](docs/README.md) - Module-specific documentation overview
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing Azure DevOps service principal entitlements into the module

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
| <a name="input_service_principal_entitlements"></a> [service\_principal\_entitlements](#input\_service\_principal\_entitlements) | List of service principal entitlements to manage. | <pre>list(object({<br/>    key                  = optional(string)<br/>    origin_id            = string<br/>    origin               = optional(string, "aad")<br/>    account_license_type = optional(string, "express")<br/>    licensing_source     = optional(string, "account")<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_principal_entitlement_descriptors"></a> [service\_principal\_entitlement\_descriptors](#output\_service\_principal\_entitlement\_descriptors) | Map of service principal entitlement descriptors keyed by entitlement key. |
| <a name="output_service_principal_entitlement_ids"></a> [service\_principal\_entitlement\_ids](#output\_service\_principal\_entitlement\_ids) | Map of service principal entitlement IDs keyed by entitlement key. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
