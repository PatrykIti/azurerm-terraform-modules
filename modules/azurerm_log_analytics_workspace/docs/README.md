# Log Analytics Workspace Module Documentation

## Overview

This module provisions a Log Analytics Workspace and optional sub-resources that
are directly tied to the workspace (solutions, data export rules, data sources,
storage insights, linked services, dedicated clusters, and CMK for clusters).
Cross-resource glue (private endpoints, Private DNS, RBAC/role assignments) is
out of scope and should be managed externally.

## Scope Exception (Current Decision)

By explicit maintainer decision, this module currently remains broader in scope
and keeps workspace-adjacent resources in a single module (no breaking split in
TASK-044). Treat this as a temporary, explicit exception to the atomic-module
guideline until a future refactor is approved.

## Managed Resources

- `azurerm_log_analytics_workspace`
- `azurerm_log_analytics_solution`
- `azurerm_log_analytics_data_export_rule`
- `azurerm_log_analytics_datasource_windows_event`
- `azurerm_log_analytics_datasource_windows_performance_counter`
- `azurerm_log_analytics_storage_insights`
- `azurerm_log_analytics_linked_service`
- `azurerm_log_analytics_cluster`
- `azurerm_log_analytics_cluster_customer_managed_key`
- `azurerm_monitor_diagnostic_setting`

## Usage Notes

- Data export rules require a destination resource ID and at least one table.
- Storage insights require a storage account key; treat it as sensitive input.
- Cluster CMK requires either `log_analytics_cluster_id` or a `cluster_name`
  that matches an item in `clusters`.
- Diagnostic settings require at least one destination and explicit log/metric
  categories.

## Out of Scope

- Private endpoints and Private DNS zones
- RBAC/role assignments
- Key Vault, storage account, or Event Hub provisioning
- Network routing and firewall rules

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on adding documentation.
