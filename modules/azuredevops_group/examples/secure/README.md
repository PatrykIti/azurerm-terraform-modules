# Secure Azure DevOps Identity Example

This example demonstrates a security-focused identity configuration with explicit memberships and minimal entitlements.

## Features

- Creates a restricted Azure DevOps group
- Adds explicit group membership with overwrite mode
- Uses stakeholder entitlements for least-privilege access (optional)

## Key Configuration

Use this pattern to keep access tightly controlled and reviewable.

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
| <a name="input_aad_group_display_name"></a> [aad\_group\_display\_name](#input\_aad\_group\_display\_name) | Optional Azure AD group display name for stakeholder entitlements. | `string` | `""` | no |
| <a name="input_group_name_prefix"></a> [group\_name\_prefix](#input\_group\_name\_prefix) | Prefix for Azure DevOps group names. | `string` | `"ado-group-secure"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_group_descriptor"></a> [group\_descriptor](#output\_group\_descriptor) | The descriptor of the Azure DevOps group. |
| <a name="output_group_id"></a> [group\_id](#output\_group\_id) | The ID of the Azure DevOps group. |
| <a name="output_group_membership_ids"></a> [group\_membership\_ids](#output\_group\_membership\_ids) | Map of group membership IDs keyed by membership key. |
<!-- END_TF_DOCS -->
