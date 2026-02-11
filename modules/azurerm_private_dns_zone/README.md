# Terraform Azure Private DNS Zone Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages Azure Private DNS Zones

## Usage

```hcl
module "azurerm_private_dns_zone" {
  source = "path/to/azurerm_private_dns_zone"

  # Required variables
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name

  # Optional configuration
  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example provisions a minimal Private DNS Zone with tags and a dedicated resource group.
- [Complete](examples/complete) - This example shows a Private DNS Zone with a custom SOA record and additional tags.
- [Secure](examples/secure) - This example focuses on a hardened Private DNS Zone deployment with clear ownership tagging.
- [Soa Record](examples/soa-record) - This example highlights how to customize the SOA record for a Private DNS Zone.
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
| [azurerm_private_dns_zone.private_dns_zone](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/private_dns_zone) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the Private DNS Zone (for example: privatelink.blob.core.windows.net). | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Private DNS Zone. | `string` | n/a | yes |
| <a name="input_soa_record"></a> [soa\_record](#input\_soa\_record) | Optional SOA record settings for the Private DNS Zone.<br/><br/>When set, email is required. Time values are expressed in seconds. | <pre>object({<br/>    email        = string<br/>    expire_time  = optional(number)<br/>    minimum_ttl  = optional(number)<br/>    refresh_time = optional(number)<br/>    retry_time   = optional(number)<br/>    ttl          = optional(number)<br/>    tags         = optional(map(string))<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Timeout configuration for creating, reading, updating, and deleting the Private DNS Zone. | <pre>object({<br/>    create = optional(string)<br/>    read   = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the Private DNS Zone. |
| <a name="output_max_number_of_virtual_network_links"></a> [max\_number\_of\_virtual\_network\_links](#output\_max\_number\_of\_virtual\_network\_links) | The maximum number of virtual network links allowed for the Private DNS Zone. |
| <a name="output_max_number_of_virtual_network_links_with_registration"></a> [max\_number\_of\_virtual\_network\_links\_with\_registration](#output\_max\_number\_of\_virtual\_network\_links\_with\_registration) | The maximum number of virtual network links with registration enabled. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Private DNS Zone. |
| <a name="output_number_of_record_sets"></a> [number\_of\_record\_sets](#output\_number\_of\_record\_sets) | The number of record sets in the Private DNS Zone. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group containing the Private DNS Zone. |
| <a name="output_soa_record"></a> [soa\_record](#output\_soa\_record) | The SOA record configuration for the Private DNS Zone. |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags assigned to the Private DNS Zone. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
