# Complete Subnet Example

This example demonstrates a comprehensive deployment of Subnet with all available features and configurations.

## Features

- Full subnet configuration with all features enabled
- Advanced networking configuration
- Diagnostic settings for monitoring and auditing
- Complete lifecycle management
- Advanced security settings
- High availability configuration

## Key Configuration

This comprehensive example showcases all available features of the subnet module, demonstrating enterprise-grade capabilities suitable for production environments.

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.36.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.36.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_subnet"></a> [subnet](#module\_subnet) | ../../ | n/a |
| <a name="module_subnet_no_delegation"></a> [subnet\_no\_delegation](#module\_subnet\_no\_delegation) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_network_security_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/network_security_group) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/resource_group) | resource |
| [azurerm_route_table.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/route_table) | resource |
| [azurerm_subnet_service_endpoint_storage_policy.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/subnet_service_endpoint_storage_policy) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Azure region for resources | `string` | `"northeurope"` | no |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Suffix for resource names to ensure uniqueness | `string` | `"002"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | <pre>{<br/>  "Environment": "Development",<br/>  "Example": "Complete",<br/>  "Module": "azurerm_subnet"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_security_group_association_id"></a> [network\_security\_group\_association\_id](#output\_network\_security\_group\_association\_id) | The ID of the NSG association |
| <a name="output_network_security_group_id"></a> [network\_security\_group\_id](#output\_network\_security\_group\_id) | The ID of the Network Security Group |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the Resource Group |
| <a name="output_route_table_association_id"></a> [route\_table\_association\_id](#output\_route\_table\_association\_id) | The ID of the Route Table association |
| <a name="output_route_table_id"></a> [route\_table\_id](#output\_route\_table\_id) | The ID of the Route Table |
| <a name="output_subnet_address_prefixes"></a> [subnet\_address\_prefixes](#output\_subnet\_address\_prefixes) | The address prefixes of the created Subnet |
| <a name="output_subnet_delegations"></a> [subnet\_delegations](#output\_subnet\_delegations) | The delegations configured on the subnet |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | The ID of the created Subnet |
| <a name="output_subnet_name"></a> [subnet\_name](#output\_subnet\_name) | The name of the created Subnet |
| <a name="output_subnet_no_delegation_id"></a> [subnet\_no\_delegation\_id](#output\_subnet\_no\_delegation\_id) | The ID of the subnet without delegation |
| <a name="output_subnet_no_delegation_name"></a> [subnet\_no\_delegation\_name](#output\_subnet\_no\_delegation\_name) | The name of the subnet without delegation |
| <a name="output_subnet_service_endpoints"></a> [subnet\_service\_endpoints](#output\_subnet\_service\_endpoints) | The service endpoints enabled on the subnet |
| <a name="output_virtual_network_name"></a> [virtual\_network\_name](#output\_virtual\_network\_name) | The name of the Virtual Network |
<!-- END_TF_DOCS -->
