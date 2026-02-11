# Terraform Azure Private DNS Zone Virtual Network Link Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages Azure Private DNS Zone Virtual Network Links

## Usage

```hcl
module "azurerm_private_dns_zone_virtual_network_link" {
  source = "path/to/azurerm_private_dns_zone_virtual_network_link"

  # Required variables
  name                  = "example-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = azurerm_virtual_network.example.id

  # Optional configuration
  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example creates a Private DNS Zone and links it to a Virtual Network.
- [Complete](examples/complete) - This example enables registration and sets the resolution policy for the VNet link.
- [Registration Enabled](examples/registration-enabled) - This example enables auto-registration of VM records in the linked virtual network.
- [Secure](examples/secure) - This example links a Private DNS Zone to a dedicated VNet intended for private endpoints.
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
| [azurerm_private_dns_zone_virtual_network_link.private_dns_zone_virtual_network_link](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/private_dns_zone_virtual_network_link) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the Private DNS Zone Virtual Network Link. | `string` | n/a | yes |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | The name of the Private DNS Zone (without a trailing dot). | `string` | n/a | yes |
| <a name="input_registration_enabled"></a> [registration\_enabled](#input\_registration\_enabled) | Whether auto-registration of virtual machine records in the linked virtual network is enabled. | `bool` | `false` | no |
| <a name="input_resolution_policy"></a> [resolution\_policy](#input\_resolution\_policy) | Optional DNS resolution policy for the link. Accepted values are Default or NxDomainRedirect. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group containing the Private DNS Zone. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Timeout configuration for creating, reading, updating, and deleting the Virtual Network Link. | <pre>object({<br/>    create = optional(string)<br/>    read   = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_virtual_network_id"></a> [virtual\_network\_id](#input\_virtual\_network\_id) | The ID of the Virtual Network to link to the Private DNS Zone. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the Private DNS Zone Virtual Network Link. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Private DNS Zone Virtual Network Link. |
| <a name="output_private_dns_zone_name"></a> [private\_dns\_zone\_name](#output\_private\_dns\_zone\_name) | The name of the Private DNS Zone associated with the link. |
| <a name="output_registration_enabled"></a> [registration\_enabled](#output\_registration\_enabled) | Whether auto-registration of VM records in the linked network is enabled. |
| <a name="output_resolution_policy"></a> [resolution\_policy](#output\_resolution\_policy) | The DNS resolution policy applied to the Virtual Network Link. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group containing the Private DNS Zone. |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags assigned to the Virtual Network Link. |
| <a name="output_virtual_network_id"></a> [virtual\_network\_id](#output\_virtual\_network\_id) | The ID of the linked Virtual Network. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
