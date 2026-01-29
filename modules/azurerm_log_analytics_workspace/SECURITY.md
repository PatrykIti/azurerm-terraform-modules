# azurerm_log_analytics_workspace Module Security

## Overview

This document outlines security-relevant configuration for the Log Analytics Workspace module.
The module manages a Log Analytics workspace and optional sub-resources
(solutions, data export rules, data sources, storage insights, linked services,
clusters, CMK, and diagnostic settings). Networking glue (private endpoints,
Private DNS, RBAC) is **out of scope** and must be handled externally.

## Security Features in This Module

### Public Ingestion and Query Controls
- **internet_ingestion_enabled** controls public ingestion access.
- **internet_query_enabled** controls public query access.
- Disable both for private-only access scenarios.

### Local Authentication
- **local_authentication_disabled** disables workspace key auth to enforce Azure AD only.
- Shared keys are still available as outputs and are marked `sensitive`.

### Resource-Only Permissions
- **allow_resource_only_permissions** controls resource-only permissions behavior.
- Keep `null` or `false` unless you explicitly require resource-only permissions.

### Managed Identities
- **identity** enables system or user-assigned identities for the workspace.
- **clusters.identity** supports system or user-assigned identities for dedicated clusters.

### Customer-Managed Keys (Clusters)
- **cluster_customer_managed_keys** allows CMK configuration for dedicated clusters.
- Key Vault and access policies are out of scope; configure externally.

### Data Export and Storage Insights
- **data_export_rules** can forward workspace data to external destinations.
- **storage_insights** requires storage account keys; treat inputs as sensitive.

### Diagnostic Settings
- **monitoring** configures diagnostic settings for audit and metrics delivery.
- Supports Log Analytics, Storage, or Event Hub destinations.

## Example: Security-Focused Configuration

```hcl
module "log_analytics_workspace" {
  source = "./modules/azurerm_log_analytics_workspace"

  name                = "law-secure"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  internet_ingestion_enabled    = false
  internet_query_enabled        = false
  local_authentication_disabled = true

  monitoring = [
    {
      name                       = "diag"
      metric_categories          = ["AllMetrics"]
      log_analytics_workspace_id = azurerm_log_analytics_workspace.audit.id
    }
  ]

  tags = {
    Environment        = "Production"
    DataClassification = "Confidential"
  }
}
```

## Security Hardening Checklist

- [ ] Disable public ingestion and query when private access is required
- [ ] Disable local authentication to enforce Azure AD
- [ ] Use managed identities where possible
- [ ] Treat storage account keys and shared keys as sensitive
- [ ] Configure diagnostic settings to a secure destination
- [ ] Apply least-privilege RBAC at the resource group and workspace levels

## Common Mistakes to Avoid

1. **Leaving public ingestion/query enabled in production**
2. **Using shared keys in long-lived applications without rotation**
3. **Exporting data to unsecured destinations**
4. **Skipping diagnostic settings configuration**

## Additional Resources

- Azure Log Analytics Workspace documentation
- Azure Monitor diagnostic settings guidance

---

**Last Updated**: 2026-01-29
