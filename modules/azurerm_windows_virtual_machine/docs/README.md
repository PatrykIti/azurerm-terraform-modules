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
- `data.azurerm_monitor_diagnostic_categories`

## Usage Notes

- **Data disks**: `data_disks` are created as managed disks and attached to the
  VM because the azurerm 4.57.0 schema does not expose inline data disk blocks
  for Windows VMs.
- **Diagnostics**: use `diagnostic_settings` with `areas` (all/logs/metrics) or
  explicit category lists. Entries with no categories are reported in
  `diagnostic_settings_skipped`.
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
