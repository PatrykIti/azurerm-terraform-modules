# Secure Redis Cache Example

This example demonstrates a security-focused Redis Cache deployment with VNet
injection and public network access disabled.

## Features

- Premium SKU with VNet injection.
- Public network access disabled.
- TLS 1.2 enforced and non-SSL port disabled.
- Access keys disabled in favor of Azure AD authentication.

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
| <a name="module_redis_cache"></a> [redis\_cache](#module\_redis\_cache) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/resource_group) | resource |
| [azurerm_subnet.redis](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/subnet) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Azure region for resources. | `string` | `"westeurope"` | no |
| <a name="input_redis_cache_name"></a> [redis\_cache\_name](#input\_redis\_cache\_name) | The name of the Redis Cache. | `string` | `"redis-secure-example"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group. | `string` | `"rg-redis-secure-example"` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the virtual network. | `string` | `"vnet-redis-secure-example"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_redis_cache_id"></a> [redis\_cache\_id](#output\_redis\_cache\_id) | The ID of the Redis Cache. |
| <a name="output_redis_cache_name"></a> [redis\_cache\_name](#output\_redis\_cache\_name) | The name of the Redis Cache. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name. |
<!-- END_TF_DOCS -->
