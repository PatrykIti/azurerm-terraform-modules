# Terraform Azure Virtual Network Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **1.2.0**
<!-- END_VERSION -->

## Description

This Terraform module creates and manages an Azure Virtual Network (VNet) and
exposes the core configuration options:

- Address spaces and DNS servers
- Flow timeout configuration
- BGP community (ExpressRoute scenarios)
- Edge zone
- Optional DDoS protection plan association
- Optional encryption enforcement
- Tags

This module manages only the VNet resource. Subnets, peerings, private endpoints,
diagnostic settings, and flow logs must be created outside the module.

## Features

- Core VNet configuration (address_space, dns_servers, flow timeout)
- Optional DDoS protection plan association
- Optional encryption enforcement
- Optional BGP community and edge zone
- Input validation for critical parameters

## Usage

### Basic Virtual Network

```hcl
module "virtual_network" {
  source = "path/to/azurerm_virtual_network"

  name                = "vnet-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

### Secure Virtual Network with DDoS Protection

```hcl
module "secure_virtual_network" {
  source = "path/to/azurerm_virtual_network"

  name                = "vnet-secure-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  # Security Configuration
  ddos_protection_plan = {
    id     = azurerm_network_ddos_protection_plan.example.id
    enable = true
  }

  encryption = {
    enforcement = "DropUnencrypted"
  }

  tags = {
    Environment   = "Production"
    SecurityLevel = "High"
  }
}
```

## Module Documentation

- [docs/README.md](docs/README.md) - Additional usage notes and guidance
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing VNet into the module

## Security Considerations

- DDoS protection requires an external DDoS plan; the module only associates it.
- Azure allows a single DDoS plan per region; reuse an existing plan when needed.
- Encryption enforcement is optional and must be set explicitly.
- DNS server configuration should be limited to trusted resolvers.
- Monitoring, diagnostic settings, NSGs, subnets, and private endpoints are out of scope.

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a basic Virtual Network configuration using secure defaults and minimal setup.
- [Complete](examples/complete) - This example demonstrates a comprehensive deployment of Virtual Network with all available features and configurations.
- [Private Endpoint](examples/private-endpoint) - This example demonstrates a Virtual Network configuration with private endpoint connectivity for enhanced security and network isolation.
- [Secure](examples/secure) - This example demonstrates a security-focused Virtual Network configuration suitable for sensitive environments.
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
| [azurerm_virtual_network.virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The address space that is used by the Virtual Network. You can supply more than one address space. | `list(string)` | n/a | yes |
| <a name="input_bgp_community"></a> [bgp\_community](#input\_bgp\_community) | The BGP community attribute in format <as-number>:<community-value>. Only applicable if the Virtual Network is connected to ExpressRoute. | `string` | `null` | no |
| <a name="input_ddos_protection_plan"></a> [ddos\_protection\_plan](#input\_ddos\_protection\_plan) | DDoS protection plan configuration for the Virtual Network. | <pre>object({<br/>    id     = string<br/>    enable = bool<br/>  })</pre> | `null` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | List of IP addresses of DNS servers for the Virtual Network. If not specified, Azure-provided DNS is used. | `list(string)` | `[]` | no |
| <a name="input_edge_zone"></a> [edge\_zone](#input\_edge\_zone) | Specifies the Edge Zone within the Azure Region where this Virtual Network should exist. | `string` | `null` | no |
| <a name="input_encryption"></a> [encryption](#input\_encryption) | Encryption configuration for the Virtual Network. | <pre>object({<br/>    enforcement = string<br/>  })</pre> | `null` | no |
| <a name="input_flow_timeout_in_minutes"></a> [flow\_timeout\_in\_minutes](#input\_flow\_timeout\_in\_minutes) | The flow timeout in minutes for the Virtual Network, which is used to enable connection tracking for intra-VM flows. Possible values are between 4 and 30 minutes. | `number` | `4` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure Region where the Virtual Network should exist. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Virtual Network. Must be unique within the resource group. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Virtual Network. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the Virtual Network and associated resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address_space"></a> [address\_space](#output\_address\_space) | The address space of the Virtual Network. |
| <a name="output_dns_servers"></a> [dns\_servers](#output\_dns\_servers) | The DNS servers configured for the Virtual Network. |
| <a name="output_guid"></a> [guid](#output\_guid) | The GUID of the Virtual Network. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Virtual Network. |
| <a name="output_location"></a> [location](#output\_location) | The Azure Region where the Virtual Network exists. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Virtual Network. |
| <a name="output_network_configuration"></a> [network\_configuration](#output\_network\_configuration) | Summary of Virtual Network configuration. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group containing the Virtual Network. |
| <a name="output_subnet"></a> [subnet](#output\_subnet) | Information about subnets defined within the Virtual Network (if any). |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
