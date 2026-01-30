# azurerm_monitor_data_collection_endpoint Module Security

## Overview

This document outlines the security-relevant configuration for the Data Collection Endpoint (DCE) module.
The module configures a DCE resource and optional diagnostic settings. Networking glue (private endpoints,
VNet integration, RBAC) is **out of scope** and must be handled externally.

## Security Features in This Module

### Public Network Access
- **public_network_access_enabled** controls public access to the endpoint.
- Recommended: disable public access when using private connectivity in your environment configuration.

### Diagnostic Settings
- **monitoring** allows configuring Azure Monitor diagnostic settings for the DCE.
- Supports Log Analytics, Storage, or Event Hub destinations.

### Tags
- Standard tags allow for governance and security classification tracking.

## Example: Security-Focused Configuration

```hcl
module "monitor_data_collection_endpoint" {
  source = "./modules/azurerm_monitor_data_collection_endpoint"

  name                = "dce-secure"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  public_network_access_enabled = false

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

- [ ] Disable public network access when private connectivity is in place
- [ ] Configure diagnostic settings to a secured destination
- [ ] Apply least-privilege RBAC on resource group and Log Analytics workspace
- [ ] Tag resources for governance and data classification

## Common Mistakes to Avoid

1. **Leaving Public Access Enabled**
   ```hcl
   # ❌ AVOID in secured environments
   public_network_access_enabled = true
   ```

2. **Missing Diagnostic Destinations**
   ```hcl
   # ❌ AVOID
   monitoring = [{
     name           = "diag"
     log_categories = ["AuditLogs"]
   }]
   ```

## Additional Resources

- Azure Monitor DCE documentation
- Azure diagnostic settings guidance

---

**Last Updated**: 2026-01-26
