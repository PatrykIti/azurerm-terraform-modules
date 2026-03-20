# Complete Managed Redis Example

This example demonstrates a fuller Managed Redis deployment with high
availability, database modules, a geo-replication group name, and diagnostic
settings streamed to Log Analytics.

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
| [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Azure region for the example resources. | `string` | `"westeurope"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_database"></a> [default\_database](#output\_default\_database) | Sanitized information about the default database. |
| <a name="output_managed_redis_hostname"></a> [managed\_redis\_hostname](#output\_managed\_redis\_hostname) | The hostname of the Managed Redis instance. |
| <a name="output_managed_redis_id"></a> [managed\_redis\_id](#output\_managed\_redis\_id) | The ID of the Managed Redis instance. |
<!-- END_TF_DOCS -->
