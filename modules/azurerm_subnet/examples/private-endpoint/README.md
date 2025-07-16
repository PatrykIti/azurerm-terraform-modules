# Private Endpoint Subnet Example

This example demonstrates a Subnet configuration with private endpoint connectivity for enhanced security and network isolation.

## Features

- Creates a subnet with private endpoint access
- Disables public network access for maximum security
- Configures virtual network and subnet for private connectivity
- Demonstrates private DNS integration
- Network isolation and secure connectivity patterns
- Enterprise-grade security configuration

## Key Configuration

This example showcases private endpoint implementation with complete network isolation, suitable for enterprise environments requiring secure connectivity without public internet exposure.

## Network Architecture

- Virtual Network with dedicated subnet for private endpoints
- Private endpoint connection to the subnet
- DNS resolution for private connectivity
- Network security group rules (if applicable)

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
| <a name="module_subnet_private_endpoint"></a> [subnet\_private\_endpoint](#module\_subnet\_private\_endpoint) | ../../ | n/a |
| <a name="module_subnet_resources"></a> [subnet\_resources](#module\_subnet\_resources) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_network_security_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/network_security_group) | resource |
| [azurerm_private_dns_a_record.storage_blob](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_zone.storage_blob](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.storage_blob](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_endpoint.storage](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/private_endpoint) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/resource_group) | resource |
| [azurerm_storage_account.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/storage_account) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Azure region for resources | `string` | `"northeurope"` | no |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Suffix for resource names to ensure uniqueness | `string` | `"004"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | <pre>{<br/>  "Environment": "Development",<br/>  "Example": "Private-Endpoint",<br/>  "Module": "azurerm_subnet"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_dns_zone_id"></a> [private\_dns\_zone\_id](#output\_private\_dns\_zone\_id) | The ID of the private DNS zone |
| <a name="output_private_dns_zone_name"></a> [private\_dns\_zone\_name](#output\_private\_dns\_zone\_name) | The name of the private DNS zone |
| <a name="output_private_endpoint_network_policies_enabled"></a> [private\_endpoint\_network\_policies\_enabled](#output\_private\_endpoint\_network\_policies\_enabled) | Network policies status for private endpoints |
| <a name="output_private_endpoint_subnet_address_prefixes"></a> [private\_endpoint\_subnet\_address\_prefixes](#output\_private\_endpoint\_subnet\_address\_prefixes) | The address prefixes of the private endpoint subnet |
| <a name="output_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#output\_private\_endpoint\_subnet\_id) | The ID of the private endpoint subnet |
| <a name="output_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#output\_private\_endpoint\_subnet\_name) | The name of the private endpoint subnet |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the Resource Group |
| <a name="output_resources_subnet_id"></a> [resources\_subnet\_id](#output\_resources\_subnet\_id) | The ID of the resources subnet |
| <a name="output_resources_subnet_name"></a> [resources\_subnet\_name](#output\_resources\_subnet\_name) | The name of the resources subnet |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The ID of the storage account |
| <a name="output_storage_private_endpoint_id"></a> [storage\_private\_endpoint\_id](#output\_storage\_private\_endpoint\_id) | The ID of the storage private endpoint |
| <a name="output_storage_private_endpoint_ip"></a> [storage\_private\_endpoint\_ip](#output\_storage\_private\_endpoint\_ip) | The private IP address of the storage private endpoint |
| <a name="output_virtual_network_name"></a> [virtual\_network\_name](#output\_virtual\_network\_name) | The name of the Virtual Network |
<!-- END_TF_DOCS -->
