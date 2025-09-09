# Terraform Azure Network Security Group Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

This module creates and manages an Azure Network Security Group (NSG) with comprehensive security rules configuration. It supports inbound and outbound rules, service tags, application security groups, and flow logs with traffic analytics. The module provides secure defaults while allowing full customization for production workloads.

## Features

- ✅ **Flexible Security Rules** - Support for inbound/outbound rules with priorities
- ✅ **Service Tags** - Use Azure service tags for simplified rule management
- ✅ **Application Security Groups** - Group VMs with similar functions
- ✅ **Flow Logs** - Capture network traffic data for analysis
- ✅ **Traffic Analytics** - Advanced network monitoring and diagnostics
- ✅ **Multiple Port Ranges** - Support for single or multiple port configurations
- ✅ **CIDR and Prefix Support** - Flexible source/destination addressing
- ✅ **Integration Ready** - Easy attachment to subnets and network interfaces

## Prerequisites

- Azure subscription with appropriate permissions
- Resource Group where the NSG will be deployed
- Network Watcher (if using flow logs)
- Storage Account (if using flow logs)
- Log Analytics Workspace (if using traffic analytics)

## Usage

### Basic Usage

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-nsg-example"
  location = "West Europe"
}

module "network_security_group" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_network_security_group?ref=NSGv1.0.0"

  # Core configuration
  name                = "nsg-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Basic security rules
  security_rules = [
    {
      name                       = "allow_ssh"
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
  ]

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

### Advanced Usage with Flow Logs and Traffic Analytics

```hcl
module "network_security_group" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_network_security_group?ref=NSGv1.0.0"

  # Core configuration
  name                = "nsg-production"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Comprehensive security rules
  security_rules = [
    {
      name                       = "allow_https"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = ["443", "8443"]
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
      description                = "Allow HTTPS from Internet"
    },
    {
      name                         = "allow_app_to_db"
      priority                     = 200
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_range            = "*"
      destination_port_range       = "1433"
      source_application_security_group_ids = [azurerm_application_security_group.app.id]
      destination_application_security_group_ids = [azurerm_application_security_group.db.id]
      description                  = "Allow application servers to database"
    },
    {
      name                       = "deny_all_inbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Deny all other inbound traffic"
    }
  ]

  # Flow logs configuration
  flow_log_enabled            = true
  flow_log_storage_account_id = azurerm_storage_account.logs.id
  flow_log_retention_in_days  = 30
  flow_log_version            = 2
  network_watcher_name        = "NetworkWatcher_westeurope"

  # Traffic analytics
  traffic_analytics_enabled             = true
  traffic_analytics_workspace_id        = azurerm_log_analytics_workspace.example.id
  traffic_analytics_workspace_region    = azurerm_log_analytics_workspace.example.location
  traffic_analytics_interval_in_minutes = 10

  tags = {
    Environment = "Production"
    Project     = "Example"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - Simple NSG with basic security rules
- [Complete](examples/complete) - Full configuration with all features
- [Secure](examples/secure) - Security-hardened configuration
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.43.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.43.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_network_security_group.network_security_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.43.0/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.security_rules](https://registry.terraform.io/providers/hashicorp/azurerm/4.43.0/docs/resources/network_security_rule) | resource |
| [azurerm_network_watcher_flow_log.flow_log](https://registry.terraform.io/providers/hashicorp/azurerm/4.43.0/docs/resources/network_watcher_flow_log) | resource |

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
| <a name="input_security_rules"></a> [security\_rules](#input\_security\_rules) | List of security rule objects to create. The `name` attribute is used as the unique identifier. | <pre>list(object({<br>    name                                       = string<br>    description                                = optional(string)<br>    priority                                   = number<br>    direction                                  = string<br>    access                                     = string<br>    protocol                                   = string<br>    source_port_range                          = optional(string)<br>    source_port_ranges                         = optional(list(string))<br>    destination_port_range                     = optional(string)<br>    destination_port_ranges                    = optional(list(string))<br>    source_address_prefix                      = optional(string)<br>    source_address_prefixes                    = optional(list(string))<br>    destination_address_prefix                 = optional(string)<br>    destination_address_prefixes               = optional(list(string))<br>    source_application_security_group_ids      = optional(list(string))<br>    destination_application_security_group_ids = optional(list(string))<br>  }))</pre> | `[]` | no |
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
<!-- END_TF_DOCS -->

## Security Considerations

This module implements several security best practices by default:

- **Explicit deny rules** - Recommended to add explicit deny rules at high priority
- **Least privilege access** - Only allow necessary ports and protocols
- **Service tags** - Use Azure service tags instead of IP ranges where possible
- **Application Security Groups** - Group resources by function for easier management
- **Flow logs** - Enable for security monitoring and compliance
- **Traffic analytics** - Gain insights into network traffic patterns
- **Regular reviews** - Audit rules regularly to remove unnecessary access

For production deployments, see the [secure example](examples/secure) which demonstrates all security features.

## Monitoring and Compliance

The module supports comprehensive monitoring through:

- **NSG Flow Logs** - Capture all network traffic for analysis
- **Traffic Analytics** - Advanced network monitoring and threat detection
- **Log Analytics Integration** - Centralized logging and alerting
- **Diagnostic Settings** - Export logs to various destinations
- **Compliance Reporting** - Support for regulatory requirements

## Best Practices

To ensure optimal security and performance:

- **Rule Priority** - Plan rule priorities carefully (100-4096)
- **Explicit Deny** - Always include explicit deny rules
- **Service Tags** - Prefer service tags over IP addresses
- **Documentation** - Document each rule's purpose
- **Regular Audits** - Review and update rules periodically
- **Testing** - Test rule changes in non-production first

## Troubleshooting

Common issues and solutions:

1. **Rules not taking effect**: Check rule priority and conflicts
2. **Flow logs not appearing**: Verify Network Watcher is enabled
3. **Traffic blocked unexpectedly**: Review all rules and their priorities
4. **Performance issues**: Consider rule complexity and number of rules

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines

## External Resources

- [Azure Network Security Groups Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
- [NSG Best Practices](https://docs.microsoft.com/en-us/azure/virtual-network/network-security-group-how-it-works)
- [Service Tags Overview](https://docs.microsoft.com/en-us/azure/virtual-network/service-tags-overview)
- [NSG Flow Logs](https://docs.microsoft.com/en-us/azure/network-watcher/network-watcher-nsg-flow-logging-overview)
