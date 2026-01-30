# Import

## Azure Monitor Private Link Scope

```hcl
import {
  to = azurerm_monitor_private_link_scope.monitor_private_link_scope
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Insights/privateLinkScopes/example-ampls"
}
```

## Scoped Service

```hcl
import {
  to = azurerm_monitor_private_link_scoped_service.scoped_service["example-scoped-service"]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Insights/privateLinkScopes/example-ampls/scopedResources/example-scoped-service"
}
```

## Diagnostic Setting

```hcl
import {
  to = azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings["diag"]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Insights/privateLinkScopes/example-ampls|diag"
}
```
