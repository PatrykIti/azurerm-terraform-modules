# Terraform Azure Network Security Group Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

This module creates and manages an Azure Network Security Group (NSG) with comprehensive security rules configuration. It supports inbound and outbound rules, service tags, application security groups, and flow logs with traffic analytics.

## Usage

```hcl
module "network_security_group" {
  source = "path/to/azurerm_network_security_group"

  # Required variables
  name                = "example-azurerm_network_security_group"
  resource_group_name = "example-rg"
  location            = "West Europe"

  # Optional configuration
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

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
