# Terraform Azure Windows Virtual Machine Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **1.0.0**
<!-- END_VERSION -->

## Description

Manages a single Azure Windows Virtual Machine with optional managed data disks,
VM extensions, and diagnostic settings. The module is designed to be atomic and
compose with network, identity, and monitoring modules in higher-level stacks.

## Usage

```hcl
module "windows_virtual_machine" {
  source = "path/to/azurerm_windows_virtual_machine"

  name                = "winvm-basic-01"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_B2s"

  network = {
    network_interface_ids = [azurerm_network_interface.example.id]
  }

  admin = {
    username = "azureuser"
    password = random_password.admin.result
  }

  image = {
    source_image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-datacenter-g2"
      version   = "latest"
    }
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
```

## Notes

- `data_disks` are implemented using `azurerm_managed_disk` +
  `azurerm_virtual_machine_data_disk_attachment` because the
  `azurerm_windows_virtual_machine` schema in azurerm 4.57.0 does not expose an
  inline data disk block.
- Use `network.primary_network_interface_id` to force NIC ordering when needed.
  The module places this NIC first in `network.network_interface_ids`.

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a basic Windows VM deployment with a public IP and
- [Boot Diagnostics](examples/boot-diagnostics) - This example enables boot diagnostics for a Windows VM using managed storage.
- [Complete](examples/complete) - This example demonstrates a feature-complete Windows VM deployment with data
- [Custom Data](examples/custom-data) - This example passes custom data to a Windows VM.
- [Data Disks](examples/data-disks) - This example demonstrates attaching managed data disks to a Windows VM.
- [Identity](examples/identity) - This example provisions a Windows VM with a system and user-assigned identity.
- [Secure](examples/secure) - This example demonstrates a hardened Windows VM deployment without a public IP
- [Spot](examples/spot) - This example provisions a Windows VM with Spot priority.
- [Vm Extensions](examples/vm-extensions) - This example provisions a Windows VM and installs a Custom Script Extension.
- [Winrm Unattend](examples/winrm-unattend) - This example configures WinRM listeners and additional unattend content.
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
| [azurerm_managed_disk.managed_disk](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/managed_disk) | resource |
| [azurerm_monitor_diagnostic_setting.monitor_diagnostic_setting](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_virtual_machine_data_disk_attachment.virtual_machine_data_disk_attachment](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_virtual_machine_extension.virtual_machine_extension](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/virtual_machine_extension) | resource |
| [azurerm_windows_virtual_machine.windows_virtual_machine](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/windows_virtual_machine) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_capabilities"></a> [additional\_capabilities](#input\_additional\_capabilities) | Additional capabilities for the VM. | <pre>object({<br/>    ultra_ssd_enabled   = optional(bool)<br/>    hibernation_enabled = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_admin"></a> [admin](#input\_admin) | Administrator configuration for the VM.<br/><br/>username: admin username.<br/>password: admin password. | <pre>object({<br/>    username = string<br/>    password = string<br/>  })</pre> | n/a | yes |
| <a name="input_boot_diagnostics"></a> [boot\_diagnostics](#input\_boot\_diagnostics) | Boot diagnostics configuration. When enabled, storage\_account\_uri may be null to use managed storage. | <pre>object({<br/>    enabled             = optional(bool, true)<br/>    storage_account_uri = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_custom_data"></a> [custom\_data](#input\_custom\_data) | Base64-encoded custom data for the VM. | `string` | `null` | no |
| <a name="input_data_disks"></a> [data\_disks](#input\_data\_disks) | Data disks attached to the VM. Each entry must have a unique name and LUN.<br/><br/>caching: None, ReadOnly, ReadWrite<br/>storage\_account\_type: Standard\_LRS, StandardSSD\_LRS, StandardSSD\_ZRS, Premium\_LRS, PremiumV2\_LRS, Premium\_ZRS, UltraSSD\_LRS | <pre>list(object({<br/>    name                      = string<br/>    lun                       = number<br/>    caching                   = string<br/>    disk_size_gb              = number<br/>    storage_account_type      = string<br/>    write_accelerator_enabled = optional(bool, false)<br/>    disk_encryption_set_id    = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Diagnostic settings configuration for the VM.<br/><br/>Provide explicit log\_categories, log\_category\_groups, and/or metric\_categories.<br/>Each entry must define at least one destination and at least one category/group/metric. | <pre>list(object({<br/>    name                           = string<br/>    log_categories                 = optional(list(string))<br/>    log_category_groups            = optional(list(string))<br/>    metric_categories              = optional(list(string))<br/>    log_analytics_workspace_id     = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_disk_controller_type"></a> [disk\_controller\_type](#input\_disk\_controller\_type) | Specifies the disk controller type for the VM. | `string` | `null` | no |
| <a name="input_edge_zone"></a> [edge\_zone](#input\_edge\_zone) | The Edge Zone within the Azure Region where this VM should exist. | `string` | `null` | no |
| <a name="input_extensions"></a> [extensions](#input\_extensions) | Virtual machine extensions to deploy. | <pre>list(object({<br/>    name                        = string<br/>    publisher                   = string<br/>    type                        = string<br/>    type_handler_version        = string<br/>    settings                    = optional(any)<br/>    protected_settings          = optional(any)<br/>    auto_upgrade_minor_version  = optional(bool)<br/>    automatic_upgrade_enabled   = optional(bool)<br/>    failure_suppression_enabled = optional(bool)<br/>    provision_after_extensions  = optional(list(string), [])<br/>    protected_settings_from_key_vault = optional(object({<br/>      secret_url      = string<br/>      source_vault_id = string<br/>    }))<br/>    tags = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_gallery_applications"></a> [gallery\_applications](#input\_gallery\_applications) | Gallery applications to install on the VM. | <pre>list(object({<br/>    version_id                                  = string<br/>    automatic_upgrade_enabled                   = optional(bool)<br/>    configuration_blob_uri                      = optional(string)<br/>    order                                       = optional(number)<br/>    tag                                         = optional(string)<br/>    treat_failure_as_deployment_failure_enabled = optional(bool)<br/>  }))</pre> | `[]` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Managed identity configuration for the VM. | <pre>object({<br/>    type         = string<br/>    identity_ids = optional(list(string), [])<br/>  })</pre> | `null` | no |
| <a name="input_image"></a> [image](#input\_image) | Image configuration for the VM.<br/><br/>Set exactly one of source\_image\_reference or source\_image\_id.<br/>plan is optional and used for marketplace images. | <pre>object({<br/>    source_image_reference = optional(object({<br/>      publisher = string<br/>      offer     = string<br/>      sku       = string<br/>      version   = string<br/>    }))<br/>    source_image_id = optional(string)<br/>    plan = optional(object({<br/>      publisher = string<br/>      product   = string<br/>      name      = string<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | Specifies the type of on-premise license for the VM (Azure Hybrid Use Benefit). | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the Windows Virtual Machine should exist. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Windows Virtual Machine. | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Network configuration for the VM.<br/><br/>network\_interface\_ids: list of NIC IDs to attach to the VM.<br/>primary\_network\_interface\_id: optional NIC ID that must belong to network\_interface\_ids. | <pre>object({<br/>    network_interface_ids        = list(string)<br/>    primary_network_interface_id = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_os_disk"></a> [os\_disk](#input\_os\_disk) | OS disk configuration.<br/><br/>caching: None, ReadOnly, ReadWrite<br/>storage\_account\_type: Standard\_LRS, StandardSSD\_LRS, StandardSSD\_ZRS, Premium\_LRS, PremiumV2\_LRS, Premium\_ZRS, UltraSSD\_LRS | <pre>object({<br/>    name                             = optional(string)<br/>    caching                          = string<br/>    storage_account_type             = string<br/>    disk_size_gb                     = optional(number)<br/>    write_accelerator_enabled        = optional(bool, false)<br/>    disk_encryption_set_id           = optional(string)<br/>    secure_vm_disk_encryption_set_id = optional(string)<br/>    security_encryption_type         = optional(string)<br/>    diff_disk_settings = optional(object({<br/>      option    = string<br/>      placement = optional(string)<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_os_image_notification"></a> [os\_image\_notification](#input\_os\_image\_notification) | OS image notification configuration. | <pre>object({<br/>    timeout = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_os_managed_disk_id"></a> [os\_managed\_disk\_id](#input\_os\_managed\_disk\_id) | The ID of an existing managed OS disk to use for the VM. | `string` | `null` | no |
| <a name="input_patching"></a> [patching](#input\_patching) | Guest patching configuration. | <pre>object({<br/>    patch_mode                                             = optional(string, "AutomaticByOS")<br/>    patch_assessment_mode                                  = optional(string, "ImageDefault")<br/>    reboot_setting                                         = optional(string)<br/>    hotpatching_enabled                                    = optional(bool)<br/>    automatic_updates_enabled                              = optional(bool)<br/>    bypass_platform_safety_checks_on_user_schedule_enabled = optional(bool)<br/>  })</pre> | `{}` | no |
| <a name="input_placement"></a> [placement](#input\_placement) | Placement and host configuration for the VM.<br/><br/>zone and availability\_set\_id are mutually exclusive.<br/>dedicated\_host\_id and dedicated\_host\_group\_id are mutually exclusive. | <pre>object({<br/>    zone                          = optional(string)<br/>    availability_set_id           = optional(string)<br/>    proximity_placement_group_id  = optional(string)<br/>    dedicated_host_id             = optional(string)<br/>    dedicated_host_group_id       = optional(string)<br/>    capacity_reservation_group_id = optional(string)<br/>    platform_fault_domain         = optional(number)<br/>    virtual_machine_scale_set_id  = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Windows Virtual Machine. | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Key Vault secrets (certificates) to inject into the VM. | <pre>list(object({<br/>    key_vault_id = string<br/>    certificates = list(object({<br/>      store = string<br/>      url   = string<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_security_profile"></a> [security\_profile](#input\_security\_profile) | Security profile settings for the VM. | <pre>object({<br/>    secure_boot_enabled        = optional(bool)<br/>    vtpm_enabled               = optional(bool)<br/>    encryption_at_host_enabled = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_size"></a> [size](#input\_size) | The size of the Windows Virtual Machine (SKU). | `string` | n/a | yes |
| <a name="input_spot"></a> [spot](#input\_spot) | Spot/priority configuration. | <pre>object({<br/>    priority        = optional(string, "Regular")<br/>    eviction_policy = optional(string)<br/>    max_bid_price   = optional(number)<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the VM. | `map(string)` | `{}` | no |
| <a name="input_termination_notification"></a> [termination\_notification](#input\_termination\_notification) | Termination notification configuration. | <pre>object({<br/>    enabled = bool<br/>    timeout = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional timeouts configuration for the VM. | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>    read   = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Base64-encoded user data for the VM. | `string` | `null` | no |
| <a name="input_vm_agent"></a> [vm\_agent](#input\_vm\_agent) | VM agent configuration. | <pre>object({<br/>    provision_vm_agent         = optional(bool, true)<br/>    allow_extension_operations = optional(bool, true)<br/>    extensions_time_budget     = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_windows_profile"></a> [windows\_profile](#input\_windows\_profile) | Windows profile settings.<br/><br/>computer\_name: Optional Windows computer name (1-15 chars, alphanumeric or hyphen).<br/>timezone: Windows time zone string (e.g., UTC, Pacific Standard Time).<br/>winrm\_listeners: WinRM listeners (protocol Http/Https; Https requires certificate\_url).<br/>additional\_unattend\_content: Unattend content blocks (AutoLogon or FirstLogonCommands). | <pre>object({<br/>    computer_name = optional(string)<br/>    timezone      = optional(string)<br/>    winrm_listeners = optional(list(object({<br/>      protocol        = string<br/>      certificate_url = optional(string)<br/>    })), [])<br/>    additional_unattend_content = optional(list(object({<br/>      setting = string<br/>      content = string<br/>    })), [])<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_disks"></a> [data\_disks](#output\_data\_disks) | Managed data disks created by the module. |
| <a name="output_diagnostic_settings_skipped"></a> [diagnostic\_settings\_skipped](#output\_diagnostic\_settings\_skipped) | Deprecated compatibility output. Diagnostic settings require explicit categories, so no entries are skipped. |
| <a name="output_extensions"></a> [extensions](#output\_extensions) | VM extensions created by the module. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Windows Virtual Machine. |
| <a name="output_identity"></a> [identity](#output\_identity) | The managed identity of the VM (if configured). |
| <a name="output_location"></a> [location](#output\_location) | The location of the Windows Virtual Machine. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Windows Virtual Machine. |
| <a name="output_network_interface_ids"></a> [network\_interface\_ids](#output\_network\_interface\_ids) | Network interface IDs attached to the VM. |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Primary private IP address of the VM (when available). |
| <a name="output_private_ip_addresses"></a> [private\_ip\_addresses](#output\_private\_ip\_addresses) | All private IP addresses associated with the VM. |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | Primary public IP address of the VM (when available). |
| <a name="output_public_ip_addresses"></a> [public\_ip\_addresses](#output\_public\_ip\_addresses) | All public IP addresses associated with the VM. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name of the Windows Virtual Machine. |
| <a name="output_virtual_machine_id"></a> [virtual\_machine\_id](#output\_virtual\_machine\_id) | The unique Virtual Machine ID. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing resources into the module
