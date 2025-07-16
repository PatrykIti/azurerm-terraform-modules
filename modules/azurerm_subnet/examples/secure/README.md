# Secure Subnet Example

This example demonstrates a maximum-security Subnet configuration suitable for highly sensitive data and regulated environments.

## Features

- Maximum security configuration with all security features enabled
- Network isolation and private endpoints
- Advanced threat protection
- Comprehensive audit logging and monitoring
- Encryption at rest and in transit
- Compliance-ready configuration

## Key Configuration

This example implements defense-in-depth security principles with multiple layers of protection suitable for highly regulated industries and sensitive workloads.

## Security Considerations

- All public access is disabled by default
- Network access is restricted to specific IP ranges
- All data is encrypted at rest and in transit
- Audit logging captures all access and modifications

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
| <a name="module_subnet_private_endpoints"></a> [subnet\_private\_endpoints](#module\_subnet\_private\_endpoints) | ../../ | n/a |

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
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Suffix for resource names to ensure uniqueness | `string` | `"003"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | <pre>{<br/>  "Environment": "Production",<br/>  "Example": "Secure",<br/>  "Module": "azurerm_subnet",<br/>  "SecurityLevel": "High"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_security_group_id"></a> [network\_security\_group\_id](#output\_network\_security\_group\_id) | The ID of the Network Security Group |
| <a name="output_network_security_group_rules"></a> [network\_security\_group\_rules](#output\_network\_security\_group\_rules) | The security rules configured in the NSG |
| <a name="output_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#output\_private\_endpoint\_subnet\_id) | The ID of the private endpoint subnet |
| <a name="output_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#output\_private\_endpoint\_subnet\_name) | The name of the private endpoint subnet |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the Resource Group |
| <a name="output_route_table_id"></a> [route\_table\_id](#output\_route\_table\_id) | The ID of the Route Table |
| <a name="output_service_endpoint_policy_id"></a> [service\_endpoint\_policy\_id](#output\_service\_endpoint\_policy\_id) | The ID of the Service Endpoint Policy |
| <a name="output_subnet_address_prefixes"></a> [subnet\_address\_prefixes](#output\_subnet\_address\_prefixes) | The address prefixes of the secure subnet |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | The ID of the secure subnet |
| <a name="output_subnet_name"></a> [subnet\_name](#output\_subnet\_name) | The name of the secure subnet |
| <a name="output_subnet_service_endpoints"></a> [subnet\_service\_endpoints](#output\_subnet\_service\_endpoints) | The service endpoints enabled on the secure subnet |
| <a name="output_virtual_network_name"></a> [virtual\_network\_name](#output\_virtual\_network\_name) | The name of the Virtual Network |
<!-- END_TF_DOCS -->
