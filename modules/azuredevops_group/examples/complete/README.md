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

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azuredevops_group"></a> [azuredevops\_group](#module\_azuredevops\_group) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azuredevops_group.member](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aad_group_display_name"></a> [aad\_group\_display\_name](#input\_aad\_group\_display\_name) | Optional Azure AD group display name for group entitlements. | `string` | `""` | no |
| <a name="input_group_name_prefix"></a> [group\_name\_prefix](#input\_group\_name\_prefix) | Prefix for Azure DevOps group names. | `string` | `"ado-group-complete"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_group_descriptor"></a> [group\_descriptor](#output\_group\_descriptor) | The descriptor of the Azure DevOps group. |
| <a name="output_group_entitlement_ids"></a> [group\_entitlement\_ids](#output\_group\_entitlement\_ids) | Map of group entitlement IDs keyed by entitlement key. |
| <a name="output_group_id"></a> [group\_id](#output\_group\_id) | The ID of the Azure DevOps group. |
| <a name="output_group_membership_ids"></a> [group\_membership\_ids](#output\_group\_membership\_ids) | Map of group membership IDs keyed by membership key. |
<!-- END_TF_DOCS -->
