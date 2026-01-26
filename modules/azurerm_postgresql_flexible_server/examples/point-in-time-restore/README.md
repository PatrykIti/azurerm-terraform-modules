# PostgreSQL Flexible Server Point-in-Time Restore Example

This example demonstrates how to restore a PostgreSQL Flexible Server to a
specific point in time. You must provide an existing source server ID and a
valid restore timestamp.

## Features

- Point-in-time restore using `create_mode`.

## Usage

```bash
terraform init
terraform plan \
  -var="source_server_id=<server-id>" \
  -var="restore_time_utc=2024-01-01T00:00:00Z"
terraform apply \
  -var="source_server_id=<server-id>" \
  -var="restore_time_utc=2024-01-01T00:00:00Z"
```

## Cleanup

```bash
terraform destroy \
  -var="source_server_id=<server-id>" \
  -var="restore_time_utc=2024-01-01T00:00:00Z"
```

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.57.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.57.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_postgresql_flexible_server"></a> [postgresql\_flexible\_server](#module\_postgresql\_flexible\_server) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/resource_group) | resource |
| [random_password.admin](https://registry.terraform.io/providers/hashicorp/random/3.6.0/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_administrator_login"></a> [administrator\_login](#input\_administrator\_login) | Administrator login for the PostgreSQL Flexible Server. | `string` | `"pgfsadmin"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the example. | `string` | `"westeurope"` | no |
| <a name="input_postgresql_version"></a> [postgresql\_version](#input\_postgresql\_version) | PostgreSQL version for the server. | `string` | `"15"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group for the example. | `string` | `"rg-pgfs-pitr-example"` | no |
| <a name="input_restore_time_utc"></a> [restore\_time\_utc](#input\_restore\_time\_utc) | Point-in-time restore timestamp in UTC (RFC3339). | `string` | n/a | yes |
| <a name="input_server_name"></a> [server\_name](#input\_server\_name) | PostgreSQL Flexible Server name for the restored server (must be globally unique). | `string` | `"pgfspitrexample001"` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU name for the PostgreSQL Flexible Server. | `string` | `"GP_Standard_D2s_v3"` | no |
| <a name="input_source_server_id"></a> [source\_server\_id](#input\_source\_server\_id) | Source PostgreSQL Flexible Server ID to restore from. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_restored_server_id"></a> [restored\_server\_id](#output\_restored\_server\_id) | The restored PostgreSQL Flexible Server ID. |
<!-- END_TF_DOCS -->
