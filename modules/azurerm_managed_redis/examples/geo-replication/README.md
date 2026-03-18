# Geo-Replication Managed Redis Example

This example demonstrates two Managed Redis instances joined into one
geo-replication group, with the primary instance managing group membership via
the module input.

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
| <a name="module_managed_redis_primary"></a> [managed\_redis\_primary](#module\_managed\_redis\_primary) | ../../ | n/a |
| <a name="module_managed_redis_secondary"></a> [managed\_redis\_secondary](#module\_managed\_redis\_secondary) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_geo_replication_group_name"></a> [geo\_replication\_group\_name](#input\_geo\_replication\_group\_name) | Geo-replication group name shared by both Managed Redis instances. | `string` | `"managed-redis-geo-example-group"` | no |
| <a name="input_primary_location"></a> [primary\_location](#input\_primary\_location) | Primary region for the first Managed Redis instance. | `string` | `"westeurope"` | no |
| <a name="input_secondary_location"></a> [secondary\_location](#input\_secondary\_location) | Secondary region for the linked Managed Redis instance. | `string` | `"centralus"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_primary_geo_replication"></a> [primary\_geo\_replication](#output\_primary\_geo\_replication) | Geo-replication membership managed on the primary instance. |
| <a name="output_primary_managed_redis_id"></a> [primary\_managed\_redis\_id](#output\_primary\_managed\_redis\_id) | The ID of the primary Managed Redis instance. |
| <a name="output_secondary_managed_redis_id"></a> [secondary\_managed\_redis\_id](#output\_secondary\_managed\_redis\_id) | The ID of the secondary Managed Redis instance. |
<!-- END_TF_DOCS -->
