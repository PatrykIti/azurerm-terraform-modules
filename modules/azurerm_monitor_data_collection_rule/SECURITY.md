# azurerm_monitor_data_collection_rule Module Security

## Overview

This document outlines the security-relevant configuration for the Data Collection Rule (DCR) module.
The module manages a DCR resource and optional diagnostic settings. Networking glue (private endpoints,
VNet integration, RBAC) is **out of scope** and must be handled externally.

## Security Features in This Module

### Managed Identity (Optional)
- **identity** can be set to `SystemAssigned` or `UserAssigned`.
- Use managed identities to avoid secrets in configuration.

### Data Collection Endpoint Association (Optional)
- **data_collection_endpoint_id** can bind the rule to a DCE that enforces network policies.
- This module does not create DCEs or networking resources.

### Diagnostic Settings
- **monitoring** allows configuring Azure Monitor diagnostic settings for the DCR.
- Supports Log Analytics, Storage, or Event Hub destinations.

### Tags
- Standard tags allow for governance and security classification tracking.

## Example: Security-Focused Configuration

```hcl
module "monitor_data_collection_rule" {
  source = "./modules/azurerm_monitor_data_collection_rule"

  name                = "dcr-secure"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  identity = {
    type = "SystemAssigned"
  }

  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.main.id

  destinations = {
    log_analytics = [
      {
        name                  = "log-analytics"
        workspace_resource_id = azurerm_log_analytics_workspace.main.id
      }
    ]
  }

  data_flows = [
    {
      streams      = ["Microsoft-Perf"]
      destinations = ["log-analytics"]
    }
  ]

  monitoring = [
    {
      name                       = "diag"
      log_categories             = ["AuditLogs"]
      metric_categories          = ["AllMetrics"]
      log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
    }
  ]

  tags = {
    Environment        = "Production"
    DataClassification = "Confidential"
  }
}
```

## Security Hardening Checklist

- [ ] Use managed identity where possible
- [ ] Bind DCR to a DCE with restricted network access
- [ ] Configure diagnostic settings to a secured destination
- [ ] Apply least-privilege RBAC on resource group and Log Analytics workspace
- [ ] Tag resources for governance and data classification

## Common Mistakes to Avoid

1. **Missing Destinations/Data Flows**
   ```hcl
   # ❌ AVOID
   destinations = {}
   data_flows   = []
   ```

2. **Mixing Linux/Windows Data Sources**
   ```hcl
   # ❌ AVOID
   kind = "Linux"
   data_sources = {
     windows_event_log = [{
       name           = "windows"
       streams        = ["Microsoft-WindowsEvent"]
       x_path_queries = ["Application!*"]
     }]
   }
   ```

## Additional Resources

- Azure Monitor DCR documentation
- Azure diagnostic settings guidance

---

**Last Updated**: 2026-01-26
