# Basic Storage Account Example

This example demonstrates a basic Azure Storage Account configuration using secure defaults and minimal setup.

## Features

- Creates a basic storage account with Standard tier and LRS replication
- Uses secure defaults (shared access keys disabled by default)
- Creates a dedicated resource group for the storage account
- Demonstrates container creation using the module's containers parameter
- Uses variables for configuration flexibility

## Key Configuration

This example uses secure defaults with shared access keys disabled. It demonstrates:
- Creating a storage container using the module's `containers` parameter
- Using variables for easy configuration customization
- Following security best practices by default

To enable shared access keys (for development or legacy compatibility), uncomment the security_settings block in main.tf.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

<!-- BEGIN_TF_DOCS -->


## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.36.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_storage_account"></a> [storage\_account](#module\_storage\_account) | github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.0.0 | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The Azure region where resources will be created | `string` | `"West Europe"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group | `string` | `"rg-storage-basic-example"` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | The name of the storage account | `string` | `"stexamplebasic001"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_location"></a> [location](#output\_location) | The Azure location where resources are deployed |
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | The primary access key for the storage account |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | The primary blob endpoint |
| <a name="output_primary_connection_string"></a> [primary\_connection\_string](#output\_primary\_connection\_string) | The primary connection string for the storage account |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The ID of the storage account |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the storage account |
<!-- END_TF_DOCS -->