# Import

## Application Insights

```hcl
import {
  to = azurerm_application_insights.application_insights
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Insights/components/example-appins"
}
```

## Diagnostic Setting

```hcl
import {
  to = azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings["diag"]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Insights/components/example-appins|diag"
}
```

## Other Sub-resources

API keys, analytics items, web tests, and smart detection rules can
be imported using their Azure resource IDs. Use the Azure portal or CLI to find
the exact IDs, then map them to the corresponding resource instances.
