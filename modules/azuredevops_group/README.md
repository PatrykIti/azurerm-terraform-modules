# Terraform Azure DevOps Group Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **1.0.0**
<!-- END_VERSION -->

## Description

Manages Azure DevOps groups with memberships and group entitlements.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_group" {
  source = "path/to/azuredevops_group"

  group_display_name = "ADO Platform Team"
  group_description  = "Platform engineering group"
}
```

Select exactly one group selector: `group_display_name` (create new) or `group_origin_id`/`group_mail` (attach existing). `group_scope` applies only when creating a new group.

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a minimal Azure DevOps identity configuration.
- [Complete](examples/complete) - This example demonstrates a group, memberships, and optional entitlements.
- [Secure](examples/secure) - This example demonstrates a security-focused identity configuration with explicit memberships and minimal entitlements.
<!-- END_EXAMPLES -->

## Module Documentation

- [docs/README.md](docs/README.md) - Module-specific documentation overview
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing Azure DevOps groups into the module


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
| [azuredevops_group.group](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/group) | resource |
| [azuredevops_group_entitlement.group_entitlement](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/group_entitlement) | resource |
| [azuredevops_group_membership.group_membership](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/group_membership) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_group_description"></a> [group\_description](#input\_group\_description) | Optional description for the Azure DevOps group; stored only when creating a new group with display\_name. | `string` | `null` | no |
| <a name="input_group_display_name"></a> [group\_display\_name](#input\_group\_display\_name) | Display name (logical name) for a new Azure DevOps group. Exactly one of group\_display\_name, group\_origin\_id, or group\_mail must be set. | `string` | `null` | no |
| <a name="input_group_entitlements"></a> [group\_entitlements](#input\_group\_entitlements) | List of group entitlements to manage for the target group. Each item must select by display\_name or origin+origin\_id; stable keys recommended. | <pre>list(object({<br/>    key                  = optional(string)<br/>    display_name         = optional(string)<br/>    origin               = optional(string)<br/>    origin_id            = optional(string)<br/>    account_license_type = optional(string, "express")<br/>    licensing_source     = optional(string, "account")<br/>  }))</pre> | `[]` | no |
| <a name="input_group_mail"></a> [group\_mail](#input\_group\_mail) | Mail address selector for an existing external group to attach instead of creating a new group (mutually exclusive with display\_name/origin\_id). | `string` | `null` | no |
| <a name="input_group_memberships"></a> [group\_memberships](#input\_group\_memberships) | List of group membership assignments. Defaults to the module-managed group when group\_descriptor is omitted; each item must include at least one member\_descriptor and a stable key/descriptor. | <pre>list(object({<br/>    key                = optional(string)<br/>    group_descriptor   = optional(string)<br/>    member_descriptors = optional(list(string), [])<br/>    mode               = optional(string, "add")<br/>  }))</pre> | `[]` | no |
| <a name="input_group_origin_id"></a> [group\_origin\_id](#input\_group\_origin\_id) | Origin ID of an existing external Azure DevOps group to attach instead of creating a new group (mutually exclusive with display\_name/mail). | `string` | `null` | no |
| <a name="input_group_scope"></a> [group\_scope](#input\_group\_scope) | Optional Azure DevOps scope path for the group when creating it (ignored for existing groups). Must be used only with display\_name (not with origin\_id/mail). | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_group_descriptor"></a> [group\_descriptor](#output\_group\_descriptor) | The descriptor of the Azure DevOps group managed by the module. |
| <a name="output_group_entitlement_descriptors"></a> [group\_entitlement\_descriptors](#output\_group\_entitlement\_descriptors) | Map of group entitlement descriptors keyed by entitlement key. |
| <a name="output_group_entitlement_ids"></a> [group\_entitlement\_ids](#output\_group\_entitlement\_ids) | Map of group entitlement IDs keyed by entitlement key. |
| <a name="output_group_id"></a> [group\_id](#output\_group\_id) | The ID of the Azure DevOps group managed by the module. |
| <a name="output_group_membership_ids"></a> [group\_membership\_ids](#output\_group\_membership\_ids) | Map of group membership IDs keyed by membership key. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
