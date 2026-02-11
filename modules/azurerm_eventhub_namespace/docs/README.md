# Event Hub Namespace Module Documentation

## Overview

This module provisions an Event Hub Namespace and optional sub-resources that
are directly tied to the namespace: authorization rules, inline network rule
set, schema registry groups, disaster recovery config, customer-managed keys,
and diagnostic settings.
Cross-resource glue (private endpoints, Private DNS, RBAC) is out of scope.

## Managed Resources

- `azurerm_eventhub_namespace`
- `azurerm_eventhub_namespace_authorization_rule`
- `azurerm_eventhub_namespace_schema_group`
- `azurerm_eventhub_namespace_disaster_recovery_config`
- `azurerm_eventhub_namespace_customer_managed_key`
- `azurerm_monitor_diagnostic_setting`

## Usage Notes

- `auto_inflate_enabled` requires `maximum_throughput_units`.
- `schema_groups` creates `azurerm_eventhub_namespace_schema_group` resources,
  and IDs are exposed via `schema_group_ids`.
- Network rule set public access must match `public_network_access_enabled`.
- Customer-managed keys require a managed identity with Key Vault permissions.
- Diagnostic settings require at least one destination and explicit categories.
- `kafka_enabled` and `zone_redundant` are not exposed in azurerm 4.57.0.

## Out of Scope

- Private endpoints and Private DNS zones
- RBAC/role assignments and policies
- Event Hub dedicated clusters (creation)
- Key Vault, storage account, and identity provisioning

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on adding documentation.
