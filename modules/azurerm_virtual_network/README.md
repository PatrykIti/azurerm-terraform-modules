# Terraform Azure Virtual Network Module

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.3.0-blue.svg)](https://www.terraform.io/)
[![AzureRM](https://img.shields.io/badge/AzureRM-4.36.0-blue.svg)](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0)

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

This Terraform module creates and manages Azure Virtual Networks with comprehensive configuration options including:

- **Core Virtual Network**: Address spaces, DNS servers, flow timeout configuration
- **Security Features**: DDoS protection, encryption enforcement, network flow logs
- **Network Peering**: Virtual network peering with customizable settings
- **DNS Integration**: Private DNS zone virtual network links
- **Monitoring**: Diagnostic settings with Log Analytics and Storage Account integration
- **BGP Support**: BGP community configuration for ExpressRoute scenarios

**Note**: This module focuses on Virtual Network resources only. For complete enterprise networking scenarios that include subnets, route tables, and network security groups, please refer to the upcoming `azurerm_networking` example in the root `examples/` directory. This comprehensive example will integrate multiple networking modules (`azurerm_virtual_network`, `azurerm_subnet`, `azurerm_route_table`, `azurerm_network_security_group`) to provide flexible configuration patterns for various enterprise scenarios.

## Features

- ✅ **Comprehensive Configuration**: Support for all Virtual Network features
- ✅ **Security-First**: DDoS protection, encryption, and comprehensive logging
- ✅ **Network Peering**: Automated peering setup with validation
- ✅ **DNS Integration**: Private DNS zone linking with registration control
- ✅ **Monitoring**: Built-in diagnostic settings and flow logs
- ✅ **Validation**: Input validation for all critical parameters
- ✅ **Lifecycle Management**: Prevent destroy protection for production environments

## Usage

### Basic Virtual Network

```hcl
module "virtual_network" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_virtual_network?ref=VNvX.X.X"

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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_virtual_network?ref=VNvX.X.X"

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

  # Monitoring
  diagnostic_settings = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    storage_account_id         = azurerm_storage_account.example.id
  }

  tags = {
    Environment   = "Production"
    SecurityLevel = "High"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
<!-- Examples list will be auto-generated here -->
<!-- END_EXAMPLES -->

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

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_diagnostic_setting.diagnostic_setting](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_network_watcher_flow_log.flow_log](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/network_watcher_flow_log) | resource |
| [azurerm_private_dns_zone_virtual_network_link.dns_zone_link](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_virtual_network.virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_peering.peering](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/virtual_network_peering) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The address space that is used by the Virtual Network. You can supply more than one address space. | `list(string)` | n/a | yes |
| <a name="input_bgp_community"></a> [bgp\_community](#input\_bgp\_community) | The BGP community attribute in format <as-number>:<community-value>. Only applicable if the Virtual Network is connected to ExpressRoute. | `string` | `null` | no |
| <a name="input_ddos_protection_plan"></a> [ddos\_protection\_plan](#input\_ddos\_protection\_plan) | DDoS protection plan configuration for the Virtual Network. | <pre>object({<br/>    id     = string<br/>    enable = bool<br/>  })</pre> | `null` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Diagnostic settings configuration for monitoring and logging. | <pre>object({<br/>    enabled                    = optional(bool, false)<br/>    log_analytics_workspace_id = optional(string)<br/>    storage_account_id         = optional(string)<br/>    eventhub_auth_rule_id      = optional(string)<br/>    logs = optional(object({<br/>      vm_protection_alerts = optional(bool, true)<br/>    }), {})<br/>    metrics = optional(object({<br/>      all_metrics = optional(bool, true)<br/>    }), {})<br/>  })</pre> | <pre>{<br/>  "enabled": false,<br/>  "logs": {<br/>    "vm_protection_alerts": true<br/>  },<br/>  "metrics": {<br/>    "all_metrics": true<br/>  }<br/>}</pre> | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | List of IP addresses of DNS servers for the Virtual Network. If not specified, Azure-provided DNS is used. | `list(string)` | `[]` | no |
| <a name="input_edge_zone"></a> [edge\_zone](#input\_edge\_zone) | Specifies the Edge Zone within the Azure Region where this Virtual Network should exist. | `string` | `null` | no |
| <a name="input_encryption"></a> [encryption](#input\_encryption) | Encryption configuration for the Virtual Network. | <pre>object({<br/>    enforcement = string<br/>  })</pre> | `null` | no |
| <a name="input_flow_log"></a> [flow\_log](#input\_flow\_log) | Network Watcher Flow Log configuration. | <pre>object({<br/>    network_watcher_name                = string<br/>    network_watcher_resource_group_name = string<br/>    network_security_group_id           = string<br/>    storage_account_id                  = string<br/>    enabled                             = optional(bool, true)<br/>    version                             = optional(number, 2)<br/>    retention_policy = optional(object({<br/>      enabled = bool<br/>      days    = number<br/>    }))<br/>    traffic_analytics = optional(object({<br/>      enabled               = bool<br/>      workspace_id          = string<br/>      workspace_region      = string<br/>      workspace_resource_id = string<br/>      interval_in_minutes   = optional(number, 10)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_flow_timeout_in_minutes"></a> [flow\_timeout\_in\_minutes](#input\_flow\_timeout\_in\_minutes) | The flow timeout in minutes for the Virtual Network, which is used to enable connection tracking for intra-VM flows. Possible values are between 4 and 30 minutes. | `number` | `4` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure Region where the Virtual Network should exist. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Virtual Network. Must be unique within the resource group. | `string` | n/a | yes |
| <a name="input_peerings"></a> [peerings](#input\_peerings) | List of Virtual Network peerings to create. | <pre>list(object({<br/>    name                         = string<br/>    remote_virtual_network_id    = string<br/>    allow_virtual_network_access = optional(bool, true)<br/>    allow_forwarded_traffic      = optional(bool, false)<br/>    allow_gateway_transit        = optional(bool, false)<br/>    use_remote_gateways          = optional(bool, false)<br/>    triggers                     = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_private_dns_zone_links"></a> [private\_dns\_zone\_links](#input\_private\_dns\_zone\_links) | List of Private DNS Zone Virtual Network Links to create. | <pre>list(object({<br/>    name                  = string<br/>    resource_group_name   = string<br/>    private_dns_zone_name = string<br/>    registration_enabled  = optional(bool, false)<br/>    tags                  = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Virtual Network. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the Virtual Network and associated resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address_space"></a> [address\_space](#output\_address\_space) | The address space of the Virtual Network. |
| <a name="output_diagnostic_setting"></a> [diagnostic\_setting](#output\_diagnostic\_setting) | Information about diagnostic settings (if configured). |
| <a name="output_dns_servers"></a> [dns\_servers](#output\_dns\_servers) | The DNS servers configured for the Virtual Network. |
| <a name="output_flow_log"></a> [flow\_log](#output\_flow\_log) | Information about Network Watcher Flow Log (if configured). |
| <a name="output_guid"></a> [guid](#output\_guid) | The GUID of the Virtual Network. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Virtual Network. |
| <a name="output_location"></a> [location](#output\_location) | The Azure Region where the Virtual Network exists. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Virtual Network. |
| <a name="output_network_configuration"></a> [network\_configuration](#output\_network\_configuration) | Summary of Virtual Network configuration. |
| <a name="output_peerings"></a> [peerings](#output\_peerings) | Information about Virtual Network peerings. |
| <a name="output_private_dns_zone_links"></a> [private\_dns\_zone\_links](#output\_private\_dns\_zone\_links) | Information about Private DNS Zone Virtual Network Links. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group containing the Virtual Network. |
| <a name="output_subnet"></a> [subnet](#output\_subnet) | Information about subnets defined within the Virtual Network (if any). |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines