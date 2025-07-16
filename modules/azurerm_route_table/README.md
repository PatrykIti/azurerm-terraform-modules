# Terraform Azure Route Table Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages Azure Route Tables with custom routes configuration, BGP route propagation settings, and subnet associations

## Usage

```hcl
module "azurerm_route_table" {
  source = "path/to/azurerm_route_table"

  # Required variables
  name                = "example-azurerm_route_table"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Optional configuration
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
- [Private Endpoint](examples/private-endpoint) - This example demonstrates a Route Table configuration with private endpoint connectivity for enhanced security and network isolation.
- [Secure](examples/secure) - This example demonstrates a maximum-security Route Table configuration suitable for highly sensitive data and regulated environments.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
# Azure Route Table Module

This module creates and manages an Azure Route Table with support for custom routes and subnet associations.

## Features

- ✅ Custom route configuration with next hop types
- ✅ BGP route propagation control
- ✅ Dynamic subnet associations
- ✅ Support for all Azure next hop types
- ✅ Comprehensive input validation
- ✅ Security-first configuration

## Usage

```hcl
module "route_table" {
  source = "../../"

  name                = "rt-hub-prod-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  disable_bgp_route_propagation = true

  routes = [
    {
      name                   = "to-firewall"
      address_prefix         = "10.0.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.1.0.4"
    },
    {
      name           = "to-internet"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
  ]

  subnet_ids_to_associate = {
    (azurerm_subnet.example.id) = azurerm_subnet.example.id
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Examples

- [Basic](examples/basic) - Simple route table with basic routes
- [Complete](examples/complete) - Full configuration with all features
- [Hub-Spoke](examples/hub-spoke) - Route table for hub-spoke network topology
- [Firewall](examples/firewall) - Route table for firewall scenarios

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
| <a name="input_disable_bgp_route_propagation"></a> [disable\_bgp\_route\_propagation](#input\_disable\_bgp\_route\_propagation) | Disable routes learned by BGP on the Route Table. Defaults to false to allow BGP route propagation. | `bool` | `false` | no |
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

## Security Considerations

### Network Security

1. **Route Table Placement**: Carefully plan route table placement to ensure traffic flows through security controls
2. **Default Routes**: Always define explicit default routes (0.0.0.0/0) to prevent unintended internet exposure
3. **Network Virtual Appliances**: When using VirtualAppliance as next hop, ensure the appliance is properly configured and secured
4. **BGP Route Propagation**: Consider disabling BGP route propagation in security-sensitive environments to maintain full control over routing

### Best Practices

- Use specific address prefixes instead of broad ranges when possible
- Regularly audit route tables to ensure they align with security policies
- Implement route tables as part of a defense-in-depth strategy
- Consider using Azure Firewall or Network Virtual Appliances for centralized security controls
- Monitor route table changes using Azure Activity Logs

### Common Security Patterns

1. **Force Tunneling**: Route all internet-bound traffic through on-premises or NVA
   ```hcl
   routes = [{
     name           = "force-tunnel-to-onprem"
     address_prefix = "0.0.0.0/0"
     next_hop_type  = "VirtualNetworkGateway"
   }]
   ```

2. **Hub-Spoke with Firewall**: Route spoke traffic through central firewall
   ```hcl
   routes = [{
     name                   = "to-hub-firewall"
     address_prefix         = "0.0.0.0/0"
     next_hop_type          = "VirtualAppliance"
     next_hop_in_ip_address = "10.0.0.4"  # Firewall IP
   }]
   ```

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
