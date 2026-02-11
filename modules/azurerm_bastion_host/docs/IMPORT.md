# Import

## Azure Bastion Host

```hcl
import {
  to = azurerm_bastion_host.bastion_host
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Network/bastionHosts/example-bastion"
}
```

## Diagnostic Setting

```hcl
import {
  to = azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings["diag"]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Network/bastionHosts/example-bastion|diag"
}
```
