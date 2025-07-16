# Terraform Azure Network Security Group Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages Azure Network Security Groups with comprehensive security rules configuration

## Usage

```hcl
module "azurerm_network_security_group" {
  source = "path/to/azurerm_network_security_group"

  # Required variables
  name                = "example-azurerm_network_security_group"
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
<!-- Examples list will be auto-generated here -->
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->


## Overview

This Terraform module creates and manages an Azure Network Security Group (NSG) with comprehensive security rules configuration. It supports inbound and outbound rules, service tags, application security groups, and flow logs with traffic analytics.

## Features

- ✅ Flexible security rule management with support for:
  - Single or multiple source/destination ports
  - Single or multiple source/destination address prefixes
  - Service tags (Internet, VirtualNetwork, AzureLoadBalancer, etc.)
  - Application Security Groups (ASGs)
- ✅ NSG Flow Logs with configurable retention
- ✅ Traffic Analytics integration for network monitoring
- ✅ Comprehensive validation for all rule parameters
- ✅ Security-first approach with secure defaults

## Usage

### Basic Example

```hcl
module "network_security_group" {
  source = "../../"

  name                = "nsg-app-prod-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  security_rules = {
    allow_ssh = {
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "10.0.0.0/8"
      destination_address_prefix = "*"
      description                = "Allow SSH from internal network"
    }
    
    allow_https = {
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow HTTPS from Internet"
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Example with Flow Logs and Traffic Analytics

```hcl
module "network_security_group" {
  source = "../../"

  name                = "nsg-app-prod-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Enable Flow Logs
  flow_log_enabled            = true
  network_watcher_name        = azurerm_network_watcher.example.name
  flow_log_storage_account_id = azurerm_storage_account.logs.id
  flow_log_retention_in_days  = 30
  flow_log_version            = 2

  # Enable Traffic Analytics
  traffic_analytics_enabled              = true
  traffic_analytics_workspace_id         = azurerm_log_analytics_workspace.example.id
  traffic_analytics_workspace_region     = azurerm_log_analytics_workspace.example.location
  traffic_analytics_interval_in_minutes  = 10

  security_rules = {
    # ... rules configuration ...
  }
}
```

## Examples

- [Basic](examples/basic) - Simple NSG with basic security rules
- [Complete](examples/complete) - Full configuration with all features
- [Secure](examples/secure) - Security-hardened configuration
- [Private Endpoint](examples/private-endpoint) - NSG for private endpoint scenarios

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
| [azurerm_network_security_group.network_security_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.security_rules](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/network_security_rule) | resource |
| [azurerm_network_watcher_flow_log.flow_log](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/network_watcher_flow_log) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_flow_log_enabled"></a> [flow\_log\_enabled](#input\_flow\_log\_enabled) | Enable NSG Flow Logs. Requires network\_watcher\_name to be set. | `bool` | `false` | no |
| <a name="input_flow_log_retention_in_days"></a> [flow\_log\_retention\_in\_days](#input\_flow\_log\_retention\_in\_days) | The number of days to retain flow log records. 0 means unlimited retention. | `number` | `7` | no |
| <a name="input_flow_log_storage_account_id"></a> [flow\_log\_storage\_account\_id](#input\_flow\_log\_storage\_account\_id) | The ID of the Storage Account where flow logs will be stored. Required if flow\_log\_enabled is true. | `string` | `null` | no |
| <a name="input_flow_log_version"></a> [flow\_log\_version](#input\_flow\_log\_version) | The version of the flow log to use. Valid values are 1 and 2. | `number` | `2` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure Region where the Network Security Group should exist. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Network Security Group. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_network_watcher_name"></a> [network\_watcher\_name](#input\_network\_watcher\_name) | The name of the Network Watcher. Required if flow\_log\_enabled is true. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Network Security Group. | `string` | n/a | yes |
| <a name="input_security_rules"></a> [security\_rules](#input\_security\_rules) | Map of security rule definitions. Each key is the rule name, and the value contains the rule configuration.<br/><br/>Important notes:<br/>- Priority must be unique within the NSG (100-4096)<br/>- Use either singular (e.g., source\_address\_prefix) or plural (e.g., source\_address\_prefixes) attributes, not both<br/>- Service tags like 'Internet', 'VirtualNetwork', 'AzureLoadBalancer' can be used in address prefixes<br/>- Application Security Groups can be referenced using their IDs<br/><br/>Example:<pre>security_rules = {<br/>  allow_ssh = {<br/>    priority                   = 100<br/>    direction                  = "Inbound"<br/>    access                     = "Allow"<br/>    protocol                   = "Tcp"<br/>    source_port_range          = "*"<br/>    destination_port_range     = "22"<br/>    source_address_prefix      = "10.0.0.0/8"<br/>    destination_address_prefix = "*"<br/>    description                = "Allow SSH from internal network"<br/>  }<br/>  allow_https_multiple = {<br/>    priority                     = 110<br/>    direction                    = "Inbound"<br/>    access                       = "Allow"<br/>    protocol                     = "Tcp"<br/>    source_port_ranges           = ["443", "8443"]<br/>    destination_port_range       = "*"<br/>    source_address_prefixes      = ["10.0.0.0/8", "172.16.0.0/12"]<br/>    destination_address_prefix   = "VirtualNetwork"<br/>  }<br/>}</pre> | <pre>map(object({<br/>    priority                                   = number<br/>    direction                                  = string<br/>    access                                     = string<br/>    protocol                                   = string<br/>    source_port_range                          = optional(string)<br/>    source_port_ranges                         = optional(list(string))<br/>    destination_port_range                     = optional(string)<br/>    destination_port_ranges                    = optional(list(string))<br/>    source_address_prefix                      = optional(string)<br/>    source_address_prefixes                    = optional(list(string))<br/>    destination_address_prefix                 = optional(string)<br/>    destination_address_prefixes               = optional(list(string))<br/>    source_application_security_group_ids      = optional(list(string))<br/>    destination_application_security_group_ids = optional(list(string))<br/>    description                                = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_traffic_analytics_enabled"></a> [traffic\_analytics\_enabled](#input\_traffic\_analytics\_enabled) | Enable Traffic Analytics for the NSG Flow Logs. | `bool` | `false` | no |
| <a name="input_traffic_analytics_interval_in_minutes"></a> [traffic\_analytics\_interval\_in\_minutes](#input\_traffic\_analytics\_interval\_in\_minutes) | The interval in minutes which Traffic Analytics will process logs. Valid values are 10 and 60. | `number` | `10` | no |
| <a name="input_traffic_analytics_workspace_id"></a> [traffic\_analytics\_workspace\_id](#input\_traffic\_analytics\_workspace\_id) | The ID of the Log Analytics workspace for Traffic Analytics. Required if traffic\_analytics\_enabled is true. | `string` | `null` | no |
| <a name="input_traffic_analytics_workspace_region"></a> [traffic\_analytics\_workspace\_region](#input\_traffic\_analytics\_workspace\_region) | The region of the Log Analytics workspace for Traffic Analytics. Required if traffic\_analytics\_enabled is true. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_flow_log_enabled"></a> [flow\_log\_enabled](#output\_flow\_log\_enabled) | Whether NSG Flow Logs are enabled |
| <a name="output_flow_log_id"></a> [flow\_log\_id](#output\_flow\_log\_id) | The ID of the NSG Flow Log resource (if enabled) |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Network Security Group |
| <a name="output_location"></a> [location](#output\_location) | The location of the Network Security Group |
| <a name="output_name"></a> [name](#output\_name) | The name of the Network Security Group |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group containing the Network Security Group |
| <a name="output_security_rule_ids"></a> [security\_rule\_ids](#output\_security\_rule\_ids) | Map of security rule names to their resource IDs |
| <a name="output_security_rules"></a> [security\_rules](#output\_security\_rules) | Map of security rule names to their full configuration |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags assigned to the Network Security Group |
| <a name="output_traffic_analytics_enabled"></a> [traffic\_analytics\_enabled](#output\_traffic\_analytics\_enabled) | Whether Traffic Analytics is enabled for the flow logs |

## Security Considerations

- Always follow the principle of least privilege when defining security rules
- Use specific source and destination addresses instead of wildcards when possible
- Enable Flow Logs and Traffic Analytics for security monitoring
- Regularly review and audit security rules
- Consider using Application Security Groups for complex scenarios

## License

MIT
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines