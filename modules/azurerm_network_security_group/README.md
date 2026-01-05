# Terraform Azure Network Security Group Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **1.1.0**
<!-- END_VERSION -->

## Description

This module creates and manages an Azure Network Security Group (NSG) with comprehensive security rules configuration. It supports inbound and outbound rules, service tags, application security groups. The module provides secure defaults while allowing full customization for production workloads.

## Features

- ✅ **Flexible Security Rules** - Support for inbound/outbound rules with priorities
- ✅ **Service Tags** - Use Azure service tags for simplified rule management
- ✅ **Application Security Groups** - Group VMs with similar functions
- ✅ **Multiple Port Ranges** - Support for single or multiple port configurations
- ✅ **CIDR and Prefix Support** - Flexible source/destination addressing
- ✅ **Integration Ready** - Easy attachment to subnets and network interfaces

## Prerequisites

- Azure subscription with appropriate permissions
- Resource Group where the NSG will be deployed

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
  source = "path/to/azurerm_network_security_group"

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

### Advanced Usage with Multiple Security Rules

```hcl
module "network_security_group" {
  source = "path/to/azurerm_network_security_group"

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

  tags = {
    Environment = "Production"
    Project     = "Example"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a basic Network Security Group configuration with simple inbound and outbound security rules.
- [Complete](examples/complete) - This example demonstrates a comprehensive deployment of Azure Network Security Group with advanced security rules and diagnostic settings.
- [Secure](examples/secure) - This example demonstrates a maximum-security Network Security Group configuration suitable for a three-tier application (web, app, db) using a zero-trust approach.
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
| [azurerm_network_security_group.network_security_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.security_rules](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/network_security_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The Azure Region where the Network Security Group should exist. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Network Security Group. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Network Security Group. | `string` | n/a | yes |
| <a name="input_security_rules"></a> [security\_rules](#input\_security\_rules) | List of security rule objects to create. The `name` attribute is used as the unique identifier.<br/><br/>Important notes:<br/>- Priority must be unique within the NSG (100-4096)<br/>- Use either singular (e.g., source\_address\_prefix) or plural (e.g., source\_address\_prefixes) attributes, not both<br/>- Service tags like 'Internet', 'VirtualNetwork', 'AzureLoadBalancer' can be used in address prefixes<br/>- Application Security Groups can be referenced using their IDs<br/><br/>Example:<pre>security_rules = [<br/>  {<br/>    name                       = "allow_ssh"<br/>    priority                   = 100<br/>    direction                  = "Inbound"<br/>    access                     = "Allow"<br/>    protocol                   = "Tcp"<br/>    source_port_range          = "*"<br/>    destination_port_range     = "22"<br/>    source_address_prefix      = "10.0.0.0/8"<br/>    destination_address_prefix = "*"<br/>    description                = "Allow SSH from internal network"<br/>  },<br/>  {<br/>    name                         = "allow_https_multiple"<br/>    priority                     = 110<br/>    direction                    = "Inbound"<br/>    access                       = "Allow"<br/>    protocol                     = "Tcp"<br/>    source_port_ranges           = ["443", "8443"]<br/>    destination_port_range       = "*"<br/>    source_address_prefixes      = ["10.0.0.0/8", "172.16.0.0/12"]<br/>    destination_address_prefix   = "VirtualNetwork"<br/>  }<br/>]</pre> | <pre>list(object({<br/>    name                                       = string<br/>    description                                = optional(string)<br/>    priority                                   = number<br/>    direction                                  = string<br/>    access                                     = string<br/>    protocol                                   = string<br/>    source_port_range                          = optional(string)<br/>    source_port_ranges                         = optional(list(string))<br/>    destination_port_range                     = optional(string)<br/>    destination_port_ranges                    = optional(list(string))<br/>    source_address_prefix                      = optional(string)<br/>    source_address_prefixes                    = optional(list(string))<br/>    destination_address_prefix                 = optional(string)<br/>    destination_address_prefixes               = optional(list(string))<br/>    source_application_security_group_ids      = optional(list(string))<br/>    destination_application_security_group_ids = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the Network Security Group |
| <a name="output_location"></a> [location](#output\_location) | The location of the Network Security Group |
| <a name="output_name"></a> [name](#output\_name) | The name of the Network Security Group |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group containing the Network Security Group |
| <a name="output_security_rule_ids"></a> [security\_rule\_ids](#output\_security\_rule\_ids) | Map of security rule names to their resource IDs |
| <a name="output_security_rules"></a> [security\_rules](#output\_security\_rules) | Map of security rule names to their full configuration |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags assigned to the Network Security Group |
<!-- END_TF_DOCS -->

## Security Considerations

This module implements several security best practices by default:

- **Explicit deny rules** - Recommended to add explicit deny rules at high priority
- **Least privilege access** - Only allow necessary ports and protocols
- **Service tags** - Use Azure service tags instead of IP ranges where possible
- **Application Security Groups** - Group resources by function for easier management
- **Regular reviews** - Audit rules regularly to remove unnecessary access

For production deployments, see the [secure example](examples/secure) which demonstrates all security features.

## Monitoring and Compliance

The module supports monitoring through:

- **Activity Logs** - Azure platform activity auditing
- **NSG Flow Logs** - Configure via Network Watcher (outside this module)
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
2. **Traffic blocked unexpectedly**: Review all rules and their priorities
3. **Performance issues**: Consider rule complexity and number of rules

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines

## External Resources

- [Azure Network Security Groups Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
- [NSG Best Practices](https://docs.microsoft.com/en-us/azure/virtual-network/network-security-group-how-it-works)
- [Service Tags Overview](https://docs.microsoft.com/en-us/azure/virtual-network/service-tags-overview)
