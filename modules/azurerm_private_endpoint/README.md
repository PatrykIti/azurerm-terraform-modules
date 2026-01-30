# Terraform Azure Private Endpoint Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages Azure Private Endpoints with optional DNS zone group support

## Usage

```hcl
module "azurerm_private_endpoint" {
  source = "path/to/azurerm_private_endpoint"

  # Required variables
  name                = "example-azurerm_private_endpoint"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connections = [
    {
      name                           = "example-psc"
      is_manual_connection           = false
      private_connection_resource_id = azurerm_storage_account.example.id
      subresource_names              = ["blob"]
    }
  ]

  # Optional configuration
  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example provisions a Private Endpoint that connects to a Storage Account (blob subresource). It also creates a VNet and subnet with private endpoint network policies disabled.
- [Complete](examples/complete) - This example demonstrates a fuller configuration, including a custom NIC name, static IP configuration, and a private DNS zone group.
- [Secure](examples/secure) - This example provisions a Private Endpoint with a private DNS zone group and a Storage Account with public network access disabled.
<!-- END_EXAMPLES -->

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

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_private_endpoint.main](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_network_interface_name"></a> [custom\_network\_interface\_name](#input\_custom\_network\_interface\_name) | The custom name of the network interface attached to the private endpoint. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_ip_configurations"></a> [ip\_configurations](#input\_ip\_configurations) | Optional static IP configuration blocks for the Private Endpoint. | <pre>list(object({<br/>    name               = string<br/>    private_ip_address = string<br/>    subresource_name   = optional(string)<br/>    member_name        = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the Private Endpoint should exist. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Private Endpoint. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_private_dns_zone_groups"></a> [private\_dns\_zone\_groups](#input\_private\_dns\_zone\_groups) | Optional private DNS zone group configuration for the Private Endpoint.<br/><br/>The provider schema allows at most one group. | <pre>list(object({<br/>    name                 = string<br/>    private_dns_zone_ids = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_private_service_connections"></a> [private\_service\_connections](#input\_private\_service\_connections) | The private service connection configuration for the Private Endpoint.<br/><br/>Exactly one connection is supported by the provider schema. | <pre>list(object({<br/>    name                            = string<br/>    is_manual_connection            = bool<br/>    private_connection_resource_id  = optional(string)<br/>    private_connection_resource_alias = optional(string)<br/>    subresource_names               = optional(list(string))<br/>    request_message                 = optional(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Private Endpoint. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the subnet from which Private IP Addresses will be allocated for this Private Endpoint. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional timeouts for Private Endpoint operations. | <pre>object({<br/>    create = optional(string)<br/>    read   = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_dns_configs"></a> [custom\_dns\_configs](#output\_custom\_dns\_configs) | The custom DNS configurations associated with the Private Endpoint. |
| <a name="output_custom_network_interface_name"></a> [custom\_network\_interface\_name](#output\_custom\_network\_interface\_name) | The custom network interface name, if configured. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Private Endpoint. |
| <a name="output_ip_configuration"></a> [ip\_configuration](#output\_ip\_configuration) | The configured static IP configuration blocks. |
| <a name="output_location"></a> [location](#output\_location) | The Azure region where the Private Endpoint exists. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Private Endpoint. |
| <a name="output_network_interface"></a> [network\_interface](#output\_network\_interface) | The network interface details created for the Private Endpoint. |
| <a name="output_private_dns_zone_configs"></a> [private\_dns\_zone\_configs](#output\_private\_dns\_zone\_configs) | The private DNS zone configurations associated with the Private Endpoint. |
| <a name="output_private_dns_zone_group"></a> [private\_dns\_zone\_group](#output\_private\_dns\_zone\_group) | The private DNS zone group configuration on the Private Endpoint. |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | The private IP address allocated to the service connection (if available). |
| <a name="output_private_service_connection"></a> [private\_service\_connection](#output\_private\_service\_connection) | The private service connection configuration and computed values. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group containing the Private Endpoint. |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | The subnet ID from which the Private Endpoint IP address is allocated. |
<!-- END_TF_DOCS -->

## Security Considerations

- Ensure the subnet used for private endpoints has `private_endpoint_network_policies` disabled.
- Configure Private DNS zones and VNet links so traffic stays private.
- Disable public network access on target resources where supported.

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
