# Complete User Entitlement Example

This example assigns two entitlements and demonstrates module iteration.

## Usage

```bash
terraform init
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

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azuredevops_user_entitlement"></a> [azuredevops\_user\_entitlement](#module\_azuredevops\_user\_entitlement) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_automation_user_origin"></a> [automation\_user\_origin](#input\_automation\_user\_origin) | Origin for the automation entitlement. | `string` | `"aad"` | no |
| <a name="input_automation_user_origin_id"></a> [automation\_user\_origin\_id](#input\_automation\_user\_origin\_id) | Origin ID for the automation entitlement. | `string` | n/a | yes |
| <a name="input_platform_user_principal_name"></a> [platform\_user\_principal\_name](#input\_platform\_user\_principal\_name) | User principal name for the platform entitlement. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_user_entitlement_descriptors"></a> [user\_entitlement\_descriptors](#output\_user\_entitlement\_descriptors) | Map of user entitlement descriptors keyed by entitlement key. |
| <a name="output_user_entitlement_ids"></a> [user\_entitlement\_ids](#output\_user\_entitlement\_ids) | Map of user entitlement IDs keyed by entitlement key. |
<!-- END_TF_DOCS -->
