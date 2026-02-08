# Terraform Azure Bastion Host Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages Azure Bastion Hosts with full SKU and feature support, plus optional diagnostic settings.

Diagnostic settings support all standard destinations, including `partner_solution_id`, and can target both explicit log categories and `log_category_groups` when exposed by the resource.

## Usage

```hcl
module "bastion_host" {
  source = "../.."

  name                = "bastion-basic-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku = "Basic"

  ip_configuration = [
    {
      name                 = "bastion-basic-ipconfig"
      subnet_id            = azurerm_subnet.bastion.id
      public_ip_address_id = azurerm_public_ip.example.id
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
```

## Security Considerations

- The Bastion Host subnet must be named `AzureBastionSubnet` and meet Azure size requirements.
- Public Bastion SKUs require a Standard, static public IP.
- Enabling advanced connectivity features (IP connect, tunneling, shareable link, file copy) expands remote access surface.

See [SECURITY.md](SECURITY.md) for detailed guidance.

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a basic deployment of the Bastion Host module using secure defaults.
- [Complete](examples/complete) - This example demonstrates a Standard SKU Bastion Host with advanced features and diagnostic settings.
- [Diagnostic Settings](examples/diagnostic-settings) - This example demonstrates configuring Azure Monitor diagnostic settings for a Bastion Host.
- [File Copy](examples/file-copy) - This example demonstrates enabling file copy on a Standard SKU Bastion Host.
- [Ip Connect](examples/ip-connect) - This example demonstrates enabling IP Connect on a Standard SKU Bastion Host.
- [Secure](examples/secure) - This example demonstrates a hardened Bastion Host configuration with restricted features and a dedicated subnet NSG.
- [Shareable Link](examples/shareable-link) - This example demonstrates enabling Shareable Link on a Standard SKU Bastion Host.
- [Tunneling](examples/tunneling) - This example demonstrates enabling native client tunneling on a Standard SKU Bastion Host.
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
| [azurerm_bastion_host.bastion_host](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/bastion_host) | resource |
| [azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/monitor_diagnostic_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_copy_paste_enabled"></a> [copy\_paste\_enabled](#input\_copy\_paste\_enabled) | Is Copy/Paste enabled for the Bastion Host? | `bool` | `true` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Diagnostic settings for the Bastion Host.<br/><br/>Supported categories for azurerm 4.57.0:<br/>- log\_categories: BastionAuditLogs<br/>- log\_category\_groups: allLogs<br/>- metric\_categories: AllMetrics | <pre>list(object({<br/>    name                           = string<br/>    log_categories                 = optional(list(string))<br/>    log_category_groups            = optional(list(string))<br/>    metric_categories              = optional(list(string))<br/>    log_analytics_workspace_id     = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>    partner_solution_id            = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_file_copy_enabled"></a> [file\_copy\_enabled](#input\_file\_copy\_enabled) | Is File Copy enabled for the Bastion Host? Supported on Standard or Premium SKU only. | `bool` | `false` | no |
| <a name="input_ip_configuration"></a> [ip\_configuration](#input\_ip\_configuration) | IP configuration for the Bastion Host (required for Basic/Standard/Premium). | <pre>list(object({<br/>    name                 = string<br/>    subnet_id            = string<br/>    public_ip_address_id = string<br/>  }))</pre> | `[]` | no |
| <a name="input_ip_connect_enabled"></a> [ip\_connect\_enabled](#input\_ip\_connect\_enabled) | Is IP Connect enabled for the Bastion Host? Supported on Standard or Premium SKU only. | `bool` | `false` | no |
| <a name="input_kerberos_enabled"></a> [kerberos\_enabled](#input\_kerberos\_enabled) | Is Kerberos authentication enabled for the Bastion Host? Supported on Standard or Premium SKU only. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the Bastion Host should exist. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Bastion Host. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Bastion Host. | `string` | n/a | yes |
| <a name="input_scale_units"></a> [scale\_units](#input\_scale\_units) | The number of scale units for the Bastion Host (2-50). Only supported with Standard or Premium SKU. | `number` | `null` | no |
| <a name="input_session_recording_enabled"></a> [session\_recording\_enabled](#input\_session\_recording\_enabled) | Is Session Recording enabled for the Bastion Host? Supported on Premium SKU only. | `bool` | `false` | no |
| <a name="input_shareable_link_enabled"></a> [shareable\_link\_enabled](#input\_shareable\_link\_enabled) | Is Shareable Link enabled for the Bastion Host? Supported on Standard or Premium SKU only. | `bool` | `false` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU of the Bastion Host. Possible values are Developer, Basic, Standard, and Premium. | `string` | `"Basic"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the Bastion Host. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Custom timeouts for the Bastion Host resource. | <pre>object({<br/>    create = optional(string)<br/>    read   = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_tunneling_enabled"></a> [tunneling\_enabled](#input\_tunneling\_enabled) | Is Tunneling enabled for the Bastion Host? Supported on Standard or Premium SKU only. | `bool` | `false` | no |
| <a name="input_virtual_network_id"></a> [virtual\_network\_id](#input\_virtual\_network\_id) | The ID of the Virtual Network for the Developer Bastion Host. | `string` | `null` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | A list of Availability Zones in which this Bastion Host should be located. | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_diagnostic_settings_skipped"></a> [diagnostic\_settings\_skipped](#output\_diagnostic\_settings\_skipped) | Deprecated compatibility output. Diagnostic settings require explicit categories, so no entries are skipped. |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | The FQDN of the Bastion Host. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Bastion Host. |
| <a name="output_ip_configuration"></a> [ip\_configuration](#output\_ip\_configuration) | The IP configuration for the Bastion Host. |
| <a name="output_location"></a> [location](#output\_location) | The location of the Bastion Host. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Bastion Host. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name of the Bastion Host. |
| <a name="output_sku"></a> [sku](#output\_sku) | The SKU of the Bastion Host. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
