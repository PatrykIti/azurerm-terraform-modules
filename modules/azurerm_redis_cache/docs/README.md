# Redis Cache Module Documentation

## Overview

The `azurerm_redis_cache` module provisions a single Azure Cache for Redis
instance and the Redis-specific sub-resources that are managed alongside it.
The module is atomic: it manages one Redis Cache and related configuration
without bundling networking glue, RBAC, or private connectivity resources.

## Managed Resources

- `azurerm_redis_cache`
- `azurerm_redis_firewall_rule`
- `azurerm_redis_linked_server`
- `azurerm_monitor_diagnostic_setting`

## Out of Scope

The following must be handled outside the module:

- Redis Enterprise resources
- Private endpoints and Private DNS zones
- RBAC/role assignments and identity provisioning for callers
- Networking glue (VNet peering, route tables, NSGs beyond Redis subnet)
- Log Analytics workspace provisioning, alerts, dashboards

## Usage Notes

- Patch schedules are configured via the `patch_schedule` block on
  `azurerm_redis_cache`. The AzureRM provider does not expose a separate
  `azurerm_redis_patch_schedule` resource in version 4.57.0.
- VNet injection requires Premium SKU, `subnet_id`, and a
  `private_static_ip_address`, and must disable public network access.
- Firewall rules are only supported when public network access is enabled.
- Persistence configuration stores storage connection strings in state; treat
  state storage as sensitive and restrict access accordingly.

## Additional References

- See `SECURITY.md` for security hardening guidance.
- See `IMPORT.md` for import instructions.
