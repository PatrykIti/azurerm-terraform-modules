# Customer Managed Key Managed Redis Example

This example demonstrates Managed Redis with customer-managed key encryption and
an attached user-assigned identity.

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.57.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.57.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_managed_redis"></a> [managed\_redis](#module\_managed\_redis) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/key_vault) | resource |
| [azurerm_key_vault_key.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/key_vault_key) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/resource_group) | resource |
| [azurerm_user_assigned_identity.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/user_assigned_identity) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | Key Vault name for the example. | `string` | `"kvmanagedrediscmk001"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the example resources. | `string` | `"westeurope"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name for the example. | `string` | `"rg-managed-redis-cmk-example"` | no |
| <a name="input_user_assigned_identity_name"></a> [user\_assigned\_identity\_name](#input\_user\_assigned\_identity\_name) | User-assigned identity name for the example. | `string` | `"uai-managed-redis-cmk"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_customer_managed_key"></a> [customer\_managed\_key](#output\_customer\_managed\_key) | The customer-managed key configuration. |
| <a name="output_managed_redis_id"></a> [managed\_redis\_id](#output\_managed\_redis\_id) | The ID of the Managed Redis instance. |
<!-- END_TF_DOCS -->
