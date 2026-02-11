# Terraform Azure Linux Virtual Machine Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages Azure Linux Virtual Machines with optional extensions and diagnostic settings.

## Usage

```hcl
module "azurerm_linux_virtual_machine" {
  source = "path/to/azurerm_linux_virtual_machine"

  name                = "linuxvm-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_B2s"

  network = {
    network_interface_ids = [azurerm_network_interface.example.id]
  }

  admin = {
    username                        = "azureuser"
    disable_password_authentication = true
    ssh_keys = [
      {
        username   = "azureuser"
        public_key = file("~/.ssh/id_rsa.pub")
      }
    ]
  }

  image = {
    source_image_reference = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "latest"
    }
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a basic Linux VM deployment with a public IP and SSH key authentication.
- [Boot Diagnostics](examples/boot-diagnostics) - This example enables boot diagnostics for a Linux VM using a dedicated storage account.
- [Complete](examples/complete) - This example demonstrates a Linux VM with data disks, boot diagnostics, managed identity, extensions, and diagnostic settings.
- [Custom Data](examples/custom-data) - This example demonstrates supplying cloud-init custom data to a Linux VM.
- [Data Disks](examples/data-disks) - This example demonstrates attaching multiple data disks to a Linux VM.
- [Identity](examples/identity) - This example demonstrates assigning a user-assigned managed identity to a Linux VM.
- [Secure](examples/secure) - This example demonstrates a security-focused Linux VM deployment without public IP exposure.
- [Spot](examples/spot) - This example demonstrates deploying a Spot-priority Linux VM.
- [Vm Extensions](examples/vm-extensions) - This example demonstrates deploying a VM extension (Custom Script) alongside a Linux VM.
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
| [azurerm_linux_virtual_machine.linux_virtual_machine](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/linux_virtual_machine) | resource |
| [azurerm_managed_disk.managed_disk](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/managed_disk) | resource |
| [azurerm_monitor_diagnostic_setting.monitor_diagnostic_setting](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_virtual_machine_data_disk_attachment.virtual_machine_data_disk_attachment](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_virtual_machine_extension.virtual_machine_extension](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/virtual_machine_extension) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_capabilities"></a> [additional\_capabilities](#input\_additional\_capabilities) | Additional capabilities for the VM. | <pre>object({<br/>    ultra_ssd_enabled   = optional(bool)<br/>    hibernation_enabled = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_admin"></a> [admin](#input\_admin) | Administrator configuration for the VM.<br/><br/>username: admin username.<br/>disable\_password\_authentication: when true, ssh\_keys must contain at least one key.<br/>password: required when disable\_password\_authentication is false.<br/>ssh\_keys: SSH public keys configured on the VM. | <pre>object({<br/>    username                        = string<br/>    disable_password_authentication = optional(bool, true)<br/>    password                        = optional(string)<br/>    ssh_keys = optional(list(object({<br/>      username   = string<br/>      public_key = string<br/>    })), [])<br/>  })</pre> | n/a | yes |
| <a name="input_boot_diagnostics"></a> [boot\_diagnostics](#input\_boot\_diagnostics) | Boot diagnostics configuration. When enabled, storage\_account\_uri may be null to use managed storage. | <pre>object({<br/>    enabled             = optional(bool, true)<br/>    storage_account_uri = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_data_disks"></a> [data\_disks](#input\_data\_disks) | Data disks attached to the VM. Each entry must have a unique name and LUN.<br/><br/>caching: None, ReadOnly, ReadWrite<br/>storage\_account\_type: Standard\_LRS, StandardSSD\_LRS, StandardSSD\_ZRS, Premium\_LRS, PremiumV2\_LRS, Premium\_ZRS, UltraSSD\_LRS<br/>create\_option: Empty or FromImage | <pre>list(object({<br/>    name                           = string<br/>    lun                            = number<br/>    caching                        = string<br/>    disk_size_gb                   = number<br/>    storage_account_type           = string<br/>    create_option                  = optional(string, "Empty")<br/>    write_accelerator_enabled      = optional(bool, false)<br/>    disk_encryption_set_id         = optional(string)<br/>    ultra_ssd_disk_iops_read_write = optional(number)<br/>    ultra_ssd_disk_mbps_read_write = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Diagnostic settings configuration for the VM.<br/><br/>Provide explicit log\_categories, log\_category\_groups, and/or metric\_categories.<br/>Each entry must define at least one destination and at least one category/group/metric. | <pre>list(object({<br/>    name                           = string<br/>    log_categories                 = optional(list(string))<br/>    metric_categories              = optional(list(string))<br/>    log_category_groups            = optional(list(string))<br/>    log_analytics_workspace_id     = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>    partner_solution_id            = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_extensions"></a> [extensions](#input\_extensions) | Virtual machine extensions to deploy. | <pre>list(object({<br/>    name                        = string<br/>    publisher                   = string<br/>    type                        = string<br/>    type_handler_version        = string<br/>    settings                    = optional(any)<br/>    protected_settings          = optional(any)<br/>    auto_upgrade_minor_version  = optional(bool)<br/>    automatic_upgrade_enabled   = optional(bool)<br/>    failure_suppression_enabled = optional(bool)<br/>    force_update_tag            = optional(string)<br/>    provision_after_extensions  = optional(list(string), [])<br/>    protected_settings_from_key_vault = optional(object({<br/>      secret_url      = string<br/>      source_vault_id = string<br/>    }))<br/>    tags = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Managed identity configuration for the VM. | <pre>object({<br/>    type         = string<br/>    identity_ids = optional(list(string), [])<br/>  })</pre> | `null` | no |
| <a name="input_image"></a> [image](#input\_image) | Image configuration for the VM.<br/><br/>Set exactly one of source\_image\_reference or source\_image\_id.<br/>plan is optional and used for marketplace images. | <pre>object({<br/>    source_image_reference = optional(object({<br/>      publisher = string<br/>      offer     = string<br/>      sku       = string<br/>      version   = string<br/>    }))<br/>    source_image_id = optional(string)<br/>    plan = optional(object({<br/>      publisher = string<br/>      product   = string<br/>      name      = string<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the Linux Virtual Machine should exist. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Linux Virtual Machine. | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Network configuration for the VM.<br/><br/>network\_interface\_ids: list of NIC IDs to attach to the VM.<br/>primary\_network\_interface\_id: optional NIC ID that must belong to network\_interface\_ids. | <pre>object({<br/>    network_interface_ids        = list(string)<br/>    primary_network_interface_id = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_os_disk"></a> [os\_disk](#input\_os\_disk) | OS disk configuration.<br/><br/>caching: None, ReadOnly, ReadWrite<br/>storage\_account\_type: Standard\_LRS, StandardSSD\_LRS, StandardSSD\_ZRS, Premium\_LRS, PremiumV2\_LRS, Premium\_ZRS, UltraSSD\_LRS | <pre>object({<br/>    name                      = optional(string)<br/>    caching                   = string<br/>    storage_account_type      = string<br/>    disk_size_gb              = optional(number)<br/>    write_accelerator_enabled = optional(bool, false)<br/>    disk_encryption_set_id    = optional(string)<br/>    diff_disk_settings = optional(object({<br/>      option    = string<br/>      placement = optional(string)<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_patching"></a> [patching](#input\_patching) | Guest patching configuration. | <pre>object({<br/>    patch_mode            = optional(string, "ImageDefault")<br/>    patch_assessment_mode = optional(string, "ImageDefault")<br/>    reboot_setting        = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_placement"></a> [placement](#input\_placement) | Placement and host configuration for the VM.<br/><br/>zone and availability\_set\_id are mutually exclusive.<br/>dedicated\_host\_id and dedicated\_host\_group\_id are mutually exclusive. | <pre>object({<br/>    zone                          = optional(string)<br/>    availability_set_id           = optional(string)<br/>    proximity_placement_group_id  = optional(string)<br/>    dedicated_host_id             = optional(string)<br/>    dedicated_host_group_id       = optional(string)<br/>    capacity_reservation_group_id = optional(string)<br/>    platform_fault_domain         = optional(number)<br/>    virtual_machine_scale_set_id  = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Linux Virtual Machine. | `string` | n/a | yes |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Runtime configuration for the VM.<br/><br/>computer\_name: optional hostname override.<br/>custom\_data: optional base64-encoded cloud-init content.<br/>user\_data: optional base64-encoded user data.<br/>gallery\_applications: gallery applications to install.<br/>secrets: Key Vault secrets/certificates to inject into the VM. | <pre>object({<br/>    computer_name = optional(string)<br/>    custom_data   = optional(string)<br/>    user_data     = optional(string)<br/>    gallery_applications = optional(list(object({<br/>      version_id                = string<br/>      automatic_upgrade_enabled = optional(bool)<br/>      configuration_blob_uri    = optional(string)<br/>    })), [])<br/>    secrets = optional(list(object({<br/>      key_vault_id = string<br/>      certificates = list(object({<br/>        url = string<br/>      }))<br/>    })), [])<br/>  })</pre> | `{}` | no |
| <a name="input_security_profile"></a> [security\_profile](#input\_security\_profile) | Security profile settings for the VM. | <pre>object({<br/>    secure_boot_enabled        = optional(bool)<br/>    vtpm_enabled               = optional(bool)<br/>    encryption_at_host_enabled = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_size"></a> [size](#input\_size) | The size of the Linux Virtual Machine (SKU). | `string` | n/a | yes |
| <a name="input_spot"></a> [spot](#input\_spot) | Spot/priority configuration. | <pre>object({<br/>    priority        = optional(string, "Regular")<br/>    eviction_policy = optional(string)<br/>    max_bid_price   = optional(number)<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the VM. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional timeouts configuration for the VM. | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>    read   = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_vm_agent"></a> [vm\_agent](#input\_vm\_agent) | VM agent configuration. | <pre>object({<br/>    provision_vm_agent         = optional(bool, true)<br/>    allow_extension_operations = optional(bool, true)<br/>    extensions_time_budget     = optional(string)<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_diagnostic_settings_skipped"></a> [diagnostic\_settings\_skipped](#output\_diagnostic\_settings\_skipped) | Deprecated compatibility output. Diagnostic settings require explicit categories, so no entries are skipped. |
| <a name="output_extensions"></a> [extensions](#output\_extensions) | VM extensions created by the module. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Linux Virtual Machine. |
| <a name="output_identity"></a> [identity](#output\_identity) | The managed identity of the VM (if configured). |
| <a name="output_location"></a> [location](#output\_location) | The location of the Linux Virtual Machine. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Linux Virtual Machine. |
| <a name="output_network_interface_ids"></a> [network\_interface\_ids](#output\_network\_interface\_ids) | Network interface IDs attached to the VM. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name of the Linux Virtual Machine. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
