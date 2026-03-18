# Managed Redis Module Documentation

## Overview

This module provisions a single Azure Managed Redis instance and can optionally
manage its geo-replication group membership. It also supports inline diagnostic
settings. The module is atomic and intentionally avoids cross-resource glue.

## Managed Resources

- `azurerm_managed_redis`
- `azurerm_managed_redis_geo_replication`
- `azurerm_monitor_diagnostic_setting`

## Usage Notes

- **Default database**: The module creates the default database by default. Set
  `default_database = null` only for troubleshooting or controlled replacement
  workflows.
- **Geo-replication**: To enable geo-replication, set
  `default_database.geo_replication_group_name` and provide the linked Managed
  Redis IDs in `geo_replication.linked_managed_redis_ids`.
- **Customer-managed keys**: CMK requires a user-assigned identity attached to
  the Managed Redis instance. The same identity must have access to the Key
  Vault key and be referenced in `customer_managed_key.user_assigned_identity_id`.
- **Diagnostics**: Diagnostic destinations such as Log Analytics, Event Hub,
  and Storage Account are intentionally passed in as IDs and managed outside
  this module.

## Out of Scope

The following are intentionally managed outside this module:

- Additional Managed Redis instances used as geo-replication peers
- Private endpoints and Private DNS integration
- Role assignments / RBAC / budgets
- Shared networking and hub-spoke topology
- Log Analytics workspaces, Event Hubs, and Storage Accounts used by diagnostics

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on adding documentation.
