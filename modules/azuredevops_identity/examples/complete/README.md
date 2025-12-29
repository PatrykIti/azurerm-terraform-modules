# Complete Azure DevOps Identity Example

This example demonstrates a group, memberships, and optional entitlements.

## Features

- Creates a primary Azure DevOps group managed by the module
- Creates a secondary group used as a membership source
- Adds group-to-group membership with a stable key
- Supports optional entitlements for users, groups, and service principals
- Includes an optional security role assignment example

## Key Configuration

Provide optional entitlement variables and set `security_role_assignment_resource_id` to enable the sample role assignment.

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```
2. Review and apply:
   ```bash
   terraform plan
   terraform apply
   ```

## Cleanup

```bash
terraform destroy
```

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
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azuredevops_identity"></a> [azuredevops\_identity](#module\_azuredevops\_identity) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azuredevops_group.member](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/group) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aad_group_display_name"></a> [aad\_group\_display\_name](#input\_aad\_group\_display\_name) | Optional Azure AD group display name for group entitlements. | `string` | `""` | no |
| <a name="input_group_name_prefix"></a> [group\_name\_prefix](#input\_group\_name\_prefix) | Prefix for Azure DevOps group names. | `string` | `"ado-identity-complete"` | no |
| <a name="input_security_role_assignment_resource_id"></a> [security\_role\_assignment\_resource\_id](#input\_security\_role\_assignment\_resource\_id) | Optional resource ID for a sample security role assignment. | `string` | `""` | no |
| <a name="input_security_role_assignment_role_name"></a> [security\_role\_assignment\_role\_name](#input\_security\_role\_assignment\_role\_name) | Role name for the optional security role assignment. | `string` | `"Reader"` | no |
| <a name="input_security_role_assignment_scope"></a> [security\_role\_assignment\_scope](#input\_security\_role\_assignment\_scope) | Scope for the optional security role assignment. | `string` | `"project"` | no |
| <a name="input_service_principal_origin_id"></a> [service\_principal\_origin\_id](#input\_service\_principal\_origin\_id) | Optional Azure AD service principal object ID for entitlement. | `string` | `""` | no |
| <a name="input_user_principal_name"></a> [user\_principal\_name](#input\_user\_principal\_name) | Optional user principal name for entitlement assignment. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_group_descriptor"></a> [group\_descriptor](#output\_group\_descriptor) | The descriptor of the Azure DevOps group. |
| <a name="output_group_entitlement_ids"></a> [group\_entitlement\_ids](#output\_group\_entitlement\_ids) | Map of group entitlement IDs keyed by entitlement key. |
| <a name="output_group_id"></a> [group\_id](#output\_group\_id) | The ID of the Azure DevOps group. |
| <a name="output_group_membership_ids"></a> [group\_membership\_ids](#output\_group\_membership\_ids) | Map of group membership IDs keyed by membership key. |
| <a name="output_securityrole_assignment_ids"></a> [securityrole\_assignment\_ids](#output\_securityrole\_assignment\_ids) | Map of security role assignment IDs keyed by assignment key. |
| <a name="output_service_principal_entitlement_ids"></a> [service\_principal\_entitlement\_ids](#output\_service\_principal\_entitlement\_ids) | Map of service principal entitlement IDs keyed by entitlement key. |
| <a name="output_user_entitlement_ids"></a> [user\_entitlement\_ids](#output\_user\_entitlement\_ids) | Map of user entitlement IDs keyed by entitlement key. |
<!-- END_TF_DOCS -->
