# Terraform Azure Route Table Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages Azure Route Tables with custom routes configuration, BGP route propagation settings, and subnet associations.

## Usage

```hcl
module "route_table" {
  source = "path/to/azurerm_route_table"

  # Required variables
  name                = "example-azurerm_route_table"
  resource_group_name = "example-rg"
  location            = "West Europe"

  # Optional configuration
  bgp_route_propagation_enabled = true
  routes = [
    {
      name                   = "to-firewall"
      address_prefix         = "10.0.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.1.0.4"
    }
  ]
  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a basic deployment of an Azure Route Table with simple route configuration.
- [Complete](examples/complete) - This example demonstrates a comprehensive deployment of Route Tables with all available features and advanced routing scenarios.
- [Secure](examples/secure) - This example demonstrates a maximum-security Route Table configuration suitable for highly sensitive data and regulated environments.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.36.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.36.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_route_table.route_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_subnet_route_table_association.associations](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bgp_route_propagation_enabled"></a> [bgp\_route\_propagation\_enabled](#input\_bgp\_route\_propagation\_enabled) | Enable BGP route propagation on the Route Table. Defaults to true. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure Region where the Route Table should exist. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Route Table. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Route Table. | `string` | n/a | yes |
| <a name="input_routes"></a> [routes](#input\_routes) | List of custom routes to create in the route table. | <pre>list(object({<br/>    name                   = string<br/>    address_prefix         = string<br/>    next_hop_type          = string<br/>    next_hop_in_ip_address = optional(string, null)<br/>  }))</pre> | `[]` | no |
| <a name="input_subnet_ids_to_associate"></a> [subnet\_ids\_to\_associate](#input\_subnet\_ids\_to\_associate) | Set of subnet IDs to associate with this route table. | `set(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_associated_subnet_ids"></a> [associated\_subnet\_ids](#output\_associated\_subnet\_ids) | List of subnet IDs associated with this Route Table |
| <a name="output_bgp_route_propagation_enabled"></a> [bgp\_route\_propagation\_enabled](#output\_bgp\_route\_propagation\_enabled) | Whether BGP route propagation is enabled on the Route Table |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Route Table |
| <a name="output_location"></a> [location](#output\_location) | The location of the Route Table |
| <a name="output_name"></a> [name](#output\_name) | The name of the Route Table |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group containing the Route Table |
| <a name="output_routes"></a> [routes](#output\_routes) | The routes within the Route Table |
| <a name="output_subnet_associations"></a> [subnet\_associations](#output\_subnet\_associations) | Map of subnet IDs to their association IDs |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags assigned to the Route Table |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines