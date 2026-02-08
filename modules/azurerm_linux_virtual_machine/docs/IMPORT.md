# Import

## Linux Virtual Machine

```hcl
import {
  to = azurerm_linux_virtual_machine.linux_virtual_machine
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Compute/virtualMachines/example-vm"
}
```

## VM Extension

```hcl
import {
  to = azurerm_virtual_machine_extension.virtual_machine_extension["custom-script"]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Compute/virtualMachines/example-vm/extensions/custom-script"
}
```

## Diagnostic Setting

```hcl
import {
  to = azurerm_monitor_diagnostic_setting.monitor_diagnostic_setting["diag"]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Compute/virtualMachines/example-vm|diag"
}
```
