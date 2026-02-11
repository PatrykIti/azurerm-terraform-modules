# Import

This module currently manages the workspace plus optional workspace-adjacent
resources:

- `azurerm_log_analytics_workspace.log_analytics_workspace`
- `azurerm_monitor_diagnostic_setting.monitor_diagnostic_setting`
- `azurerm_log_analytics_solution.log_analytics_solution`
- `azurerm_log_analytics_data_export_rule.log_analytics_data_export_rule`
- `azurerm_log_analytics_datasource_windows_event.log_analytics_datasource_windows_event`
- `azurerm_log_analytics_datasource_windows_performance_counter.log_analytics_datasource_windows_performance_counter`
- `azurerm_log_analytics_storage_insights.log_analytics_storage_insights`
- `azurerm_log_analytics_linked_service.log_analytics_linked_service`
- `azurerm_log_analytics_cluster.log_analytics_cluster`
- `azurerm_log_analytics_cluster_customer_managed_key.log_analytics_cluster_customer_managed_key`

## Import Mapping Limits

- For `for_each` resources, the state address key must match the configured
  `name` in `features`/`diagnostic_settings`.
- `monitor_diagnostic_setting` keys map to `diagnostic_settings[*].name`.
- Diagnostic setting entries are validated before apply: each entry must include
  at least one non-empty destination ID and at least one non-empty log/metric
  category.
- Cross-resource glue remains out of scope (private endpoints, RBAC, DNS, etc.)
  and cannot be imported through this module.

## Log Analytics Workspace

```hcl
import {
  to = azurerm_log_analytics_workspace.log_analytics_workspace
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.OperationalInsights/workspaces/example-law"
}
```

## Diagnostic Setting

```hcl
import {
  to = azurerm_monitor_diagnostic_setting.monitor_diagnostic_setting["diag"]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.OperationalInsights/workspaces/example-law|diag"
}
```

## Sub-resources

Examples (replace IDs with your real resources):

```hcl
import {
  to = azurerm_log_analytics_solution.log_analytics_solution["ContainerInsights"]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.OperationsManagement/solutions/ContainerInsights(example-law)"
}

import {
  to = azurerm_log_analytics_data_export_rule.log_analytics_data_export_rule["export-heartbeat"]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.OperationalInsights/workspaces/example-law/dataExports/export-heartbeat"
}
```

Other sub-resources can be imported with their exact Azure resource IDs. Use
Azure Portal/CLI to fetch IDs, then map them to the matching `for_each` key.
