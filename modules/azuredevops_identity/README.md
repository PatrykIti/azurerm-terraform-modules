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

  group_display_name = "ADO Platform Team"
  group_description  = "Platform engineering group"
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a minimal Azure DevOps identity configuration.
- [Complete](examples/complete) - This example demonstrates a group, memberships, entitlements, and a role assignment.
- [Secure](examples/secure) - This example demonstrates a security-focused identity configuration with explicit memberships and minimal entitlements.
<!-- END_EXAMPLES -->

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
| [azuredevops_securityrole_assignment.securityrole_assignment](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/securityrole_assignment) | resource |
| [azuredevops_service_principal_entitlement.service_principal_entitlement](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/service_principal_entitlement) | resource |
| [azuredevops_user_entitlement.user_entitlement](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/user_entitlement) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_group_description"></a> [group\_description](#input\_group\_description) | Description for the Azure DevOps group. Only used when creating a new group. | `string` | `null` | no |
| <a name="input_group_display_name"></a> [group\_display\_name](#input\_group\_display\_name) | Display name for the Azure DevOps group. Required when creating a new group. | `string` | `null` | no |
| <a name="input_group_entitlements"></a> [group\_entitlements](#input\_group\_entitlements) | List of group entitlements to manage. | <pre>list(object({<br/>    key                  = optional(string)<br/>    display_name         = optional(string)<br/>    origin               = optional(string)<br/>    origin_id            = optional(string)<br/>    account_license_type = optional(string, "express")<br/>    licensing_source     = optional(string, "account")<br/>  }))</pre> | `[]` | no |
| <a name="input_group_mail"></a> [group\_mail](#input\_group\_mail) | Mail address of an external group to attach instead of creating a new group. | `string` | `null` | no |
| <a name="input_group_memberships"></a> [group\_memberships](#input\_group\_memberships) | List of group membership assignments. | <pre>list(object({<br/>    key                = optional(string)<br/>    group_descriptor   = optional(string)<br/>    member_descriptors = optional(list(string), [])<br/>    mode               = optional(string, "add")<br/>  }))</pre> | `[]` | no |
| <a name="input_group_origin_id"></a> [group\_origin\_id](#input\_group\_origin\_id) | Origin ID of an external group to attach instead of creating a new group. | `string` | `null` | no |
| <a name="input_group_scope"></a> [group\_scope](#input\_group\_scope) | Scope for the Azure DevOps group. Only valid when creating a new group. | `string` | `null` | no |
| <a name="input_securityrole_assignments"></a> [securityrole\_assignments](#input\_securityrole\_assignments) | List of security role assignments to manage. | <pre>list(object({<br/>    key         = optional(string)<br/>    scope       = string<br/>    resource_id = string<br/>    role_name   = string<br/>    identity_id = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_service_principal_entitlements"></a> [service\_principal\_entitlements](#input\_service\_principal\_entitlements) | List of service principal entitlements to manage. | <pre>list(object({<br/>    key                  = optional(string)<br/>    origin_id            = string<br/>    origin               = optional(string, "aad")<br/>    account_license_type = optional(string, "express")<br/>    licensing_source     = optional(string, "account")<br/>  }))</pre> | `[]` | no |
| <a name="input_user_entitlements"></a> [user\_entitlements](#input\_user\_entitlements) | List of user entitlements to manage. | <pre>list(object({<br/>    key                  = optional(string)<br/>    principal_name       = optional(string)<br/>    origin_id            = optional(string)<br/>    origin               = optional(string)<br/>    account_license_type = optional(string, "express")<br/>    licensing_source     = optional(string, "account")<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_group_descriptor"></a> [group\_descriptor](#output\_group\_descriptor) | The descriptor of the Azure DevOps group managed by the module. |
| <a name="output_group_entitlement_descriptors"></a> [group\_entitlement\_descriptors](#output\_group\_entitlement\_descriptors) | Map of group entitlement descriptors keyed by entitlement key. |
| <a name="output_group_entitlement_ids"></a> [group\_entitlement\_ids](#output\_group\_entitlement\_ids) | Map of group entitlement IDs keyed by entitlement key. |
| <a name="output_group_id"></a> [group\_id](#output\_group\_id) | The ID of the Azure DevOps group managed by the module. |
| <a name="output_group_membership_ids"></a> [group\_membership\_ids](#output\_group\_membership\_ids) | Map of group membership IDs keyed by membership key. |
| <a name="output_securityrole_assignment_ids"></a> [securityrole\_assignment\_ids](#output\_securityrole\_assignment\_ids) | Map of security role assignment IDs keyed by assignment key. |
| <a name="output_service_principal_entitlement_descriptors"></a> [service\_principal\_entitlement\_descriptors](#output\_service\_principal\_entitlement\_descriptors) | Map of service principal entitlement descriptors keyed by entitlement key. |
| <a name="output_service_principal_entitlement_ids"></a> [service\_principal\_entitlement\_ids](#output\_service\_principal\_entitlement\_ids) | Map of service principal entitlement IDs keyed by entitlement key. |
| <a name="output_user_entitlement_descriptors"></a> [user\_entitlement\_descriptors](#output\_user\_entitlement\_descriptors) | Map of user entitlement descriptors keyed by entitlement key. |
| <a name="output_user_entitlement_ids"></a> [user\_entitlement\_ids](#output\_user\_entitlement\_ids) | Map of user entitlement IDs keyed by entitlement key. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [docs/IMPORT.md](docs/IMPORT.md) - Import existing Azure DevOps identities into the module
- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
