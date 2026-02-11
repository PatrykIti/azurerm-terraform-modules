# Linux Virtual Machine Module Documentation

## Overview

This module provisions a single Azure Linux Virtual Machine and VM-scoped resources:

- `azurerm_linux_virtual_machine`
- `azurerm_virtual_machine_extension`
- `azurerm_monitor_diagnostic_setting`

## Managed Resources

- Linux VM with configurable OS/data disks, availability/host settings, and security profile
- Optional VM extensions (Custom Script, AAD login, monitoring agents, etc.)
- Optional diagnostic settings with explicit log categories, log category groups, and metric categories

## Usage Notes

- Network resources (VNet, subnet, NIC, NSG, public IP) must be created outside this module.
- Diagnostic settings destinations (Log Analytics, Storage, Event Hub) are external resources.
- Customer-managed keys and Key Vault configuration are out of scope.

## Out of Scope

- VNet/subnet and network security groups
- Network interfaces and public IPs
- Role assignments/RBAC
- Private DNS and Private Endpoints
- Log Analytics workspace creation
- Backup/Recovery Services Vault

See the main README for usage examples and input/output details.
