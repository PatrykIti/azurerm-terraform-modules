# Log Analytics Cluster CMK Example

This example configures a customer-managed key for a Log Analytics cluster.

## Usage

```bash
terraform init
terraform apply
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
| <a name="module_log_analytics_workspace"></a> [log\_analytics\_workspace](#module\_log\_analytics\_workspace) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/key_vault) | resource |
| [azurerm_key_vault_access_policy.cluster](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_key.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/key_vault_key) | resource |
| [azurerm_log_analytics_cluster.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/log_analytics_cluster) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/resource_group) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_location"></a> [cluster\_location](#input\_cluster\_location) | Azure region for the Log Analytics cluster. | `string` | `"westeurope"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Log Analytics cluster name. | `string` | `"law-cmk-cluster"` | no |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | Key Vault name for CMK. | `string` | `"kvlawcmkexample"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for resources. | `string` | `"westeurope"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name for the example. | `string` | `"rg-law-cmk-example"` | no |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | Log Analytics Workspace name. | `string` | `"law-cmk-example"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_customer_managed_keys"></a> [cluster\_customer\_managed\_keys](#output\_cluster\_customer\_managed\_keys) | Cluster CMK resources created by the module. |
<!-- END_TF_DOCS -->