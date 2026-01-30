# Linked Server Redis Cache Example

This example demonstrates linking a primary Redis Cache to a secondary cache
using the linked server feature (Premium SKU) across two regions.

## Features

- Two Premium Redis Cache instances in different regions.
- Linked server configuration for geo-replication.

## Usage

```bash
terraform init
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
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.57.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.57.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_redis_primary"></a> [redis\_primary](#module\_redis\_primary) | ../.. | n/a |
| <a name="module_redis_secondary"></a> [redis\_secondary](#module\_redis\_secondary) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_primary_cache_name"></a> [primary\_cache\_name](#input\_primary\_cache\_name) | The name of the primary Redis Cache. | `string` | `"redis-linked-primary"` | no |
| <a name="input_primary_location"></a> [primary\_location](#input\_primary\_location) | Azure region for the primary Redis Cache. | `string` | `"westeurope"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group. | `string` | `"rg-redis-linked-example"` | no |
| <a name="input_secondary_cache_name"></a> [secondary\_cache\_name](#input\_secondary\_cache\_name) | The name of the secondary Redis Cache. | `string` | `"redis-linked-secondary"` | no |
| <a name="input_secondary_location"></a> [secondary\_location](#input\_secondary\_location) | Azure region for the secondary Redis Cache. | `string` | `"northeurope"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_primary_cache_id"></a> [primary\_cache\_id](#output\_primary\_cache\_id) | The ID of the primary Redis Cache. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name. |
| <a name="output_secondary_cache_id"></a> [secondary\_cache\_id](#output\_secondary\_cache\_id) | The ID of the secondary Redis Cache. |
<!-- END_TF_DOCS -->
