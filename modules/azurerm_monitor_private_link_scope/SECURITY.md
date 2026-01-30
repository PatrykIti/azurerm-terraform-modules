# azurerm_monitor_private_link_scope Module Security

## Overview

This module manages Azure Monitor Private Link Scopes (AMPLS) and optional scoped services.
AMPLS controls private connectivity for Azure Monitor ingestion/query. Private endpoints and DNS are
out of scope and must be configured separately.

## Security Features

### Access Modes
- **ingestion_access_mode** controls whether ingestion is PrivateOnly or Open.
- **query_access_mode** controls whether query is PrivateOnly or Open.

Secure default: both modes default to `PrivateOnly`.

### Diagnostic Settings
Optional diagnostic settings can forward logs/metrics to Log Analytics, Storage, or Event Hub.
Provide explicit categories to avoid unintended data exposure.

## Secure Configuration Example

```hcl
module "monitor_private_link_scope" {
  source = "./modules/azurerm_monitor_private_link_scope"

  name                = "example-ampls"
  resource_group_name = azurerm_resource_group.example.name

  ingestion_access_mode = "PrivateOnly"
  query_access_mode     = "PrivateOnly"

  scoped_services = [
    {
      name               = "ampls-law"
      linked_resource_id = azurerm_log_analytics_workspace.example.id
    }
  ]

  monitoring = [
    {
      name                       = "diag"
      log_categories             = ["AuditEvent"]
      metric_categories          = ["AllMetrics"]
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    }
  ]
}
```

## Security Checklist

- [ ] Use `PrivateOnly` for ingestion and query when possible
- [ ] Create private endpoints and DNS zones outside this module
- [ ] Limit scoped services to required resources only
- [ ] Configure diagnostic settings with explicit categories
- [ ] Apply RBAC and least-privilege access in the resource group

## Common Mistakes

1. **Open access modes in production**
   ```hcl
   # ❌ Avoid in production
   ingestion_access_mode = "Open"
   query_access_mode     = "Open"
   ```

2. **Missing private endpoints/DNS**
   AMPLS does not create private endpoints. Without them, PrivateOnly modes will block ingestion/query.

## Additional Resources

- Azure Monitor Private Link documentation
- Azure Monitor diagnostic settings guidance
