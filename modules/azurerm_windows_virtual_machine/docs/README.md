# Windows Virtual Machine Module Documentation

## Overview

The `azurerm_windows_virtual_machine` module manages a single Azure Windows VM
with optional managed data disks, VM extensions, and diagnostic settings.
Diagnostics are configured inline to avoid cross-module coupling.

## Managed Resources

- `azurerm_windows_virtual_machine`
- `azurerm_managed_disk` (for `data_disks`)
- `azurerm_virtual_machine_data_disk_attachment`
- `azurerm_virtual_machine_extension`
- `azurerm_monitor_diagnostic_setting`

## Usage Notes

- **Data disks**: `data_disks` are created as managed disks and attached to the
  VM because the azurerm 4.57.0 schema does not expose inline data disk blocks
  for Windows VMs.
- **Diagnostics**: use explicit `diagnostic_settings.log_categories`,
  `log_category_groups`, and/or `metric_categories`. No category auto-discovery
  is performed.
- **Disk encryption sets**: when `os_disk.disk_encryption_set_id` or
  `os_disk.secure_vm_disk_encryption_set_id` is set, `identity.type` must include
  `UserAssigned`.
- **Patching**: `patch_mode = AutomaticByPlatform` requires `vm_agent.provision_vm_agent = true`.
  Hotpatching also requires AutomaticByPlatform and VM agent enabled.
- **WinRM**: Use HTTPS with a certificate for production workloads.

## Out-of-scope Resources

The module intentionally does **not** create the following resources:

- Virtual networks, subnets, NICs, NSGs, public IPs, load balancers
- Private DNS zones and links
- RBAC / role assignments
- Log Analytics workspace, storage accounts, or Event Hub resources for diagnostics
- Backup / Recovery Services vaults
- Key Vault management (only certificate references are used)

Use dedicated modules or higher-level compositions for these dependencies.
