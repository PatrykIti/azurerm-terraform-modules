# Bastion Host Module Documentation

## Overview

This module provisions a single Azure Bastion Host and optional Azure Monitor diagnostic settings. It supports Developer, Basic, Standard, and Premium SKUs and exposes feature flags for the Standard/Premium capabilities.

## Managed Resources

- `azurerm_bastion_host`
- `azurerm_monitor_diagnostic_setting` (optional, one or more)

## Usage Notes

- Public Bastion SKUs (Basic/Standard/Premium) require an `AzureBastionSubnet` and a Standard, static public IP address.
- The Developer SKU uses `virtual_network_id` and does not use a public IP or `ip_configuration`.
- Diagnostic settings support `areas` mapping (`all`, `logs`, `metrics`, `audit`), explicit `log_category_groups`, and partner destinations via `partner_solution_id`.

## Out of Scope

The following resources remain outside this module and should be created separately (see examples):

- Virtual network and `AzureBastionSubnet`
- Public IP address
- Network Security Groups / UDRs for the Bastion subnet
- Log Analytics workspace or other diagnostic destinations
- Role assignments/RBAC and private DNS configuration
