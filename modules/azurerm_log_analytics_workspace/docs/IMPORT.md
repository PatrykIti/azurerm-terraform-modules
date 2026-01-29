# Import

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
  to = azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings["diag"]
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

Other sub-resources (data sources, storage insights, linked services, clusters, CMK)
can be imported using their Azure resource IDs. Use the Azure portal or CLI to
retrieve the exact IDs, then map them to the corresponding resource instances.
