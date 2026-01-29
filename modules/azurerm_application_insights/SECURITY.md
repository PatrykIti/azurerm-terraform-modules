# azurerm_application_insights Module Security

## Overview

This document outlines security-relevant configuration for the Application Insights module.
The module manages an Application Insights resource and optional sub-resources
(API keys, analytics items, web tests, workbooks, smart detection rules, and
diagnostic settings). Networking glue (private endpoints, Private DNS, RBAC)
is **out of scope** and must be handled externally.

## Security Features in This Module

### Public Ingestion and Query Controls
- **internet_ingestion_enabled** controls public ingestion access.
- **internet_query_enabled** controls public query access.
- Disable both for private-only access scenarios.

### Local Authentication
- **local_authentication_disabled** disables local auth to enforce Azure AD only.

### IP Masking
- **disable_ip_masking** defaults to false, keeping IP masking enabled.

### API Keys
- **api_keys** outputs are marked sensitive.
- Use least-privilege permissions and rotate keys regularly.

### Diagnostic Settings
- **monitoring** configures diagnostic settings for audit and metrics delivery.
- Supports Log Analytics, Storage, or Event Hub destinations.

## Example: Security-Focused Configuration

```hcl
module "application_insights" {
  source = "./modules/azurerm_application_insights"

  name                = "appi-secure"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.main.id

  internet_ingestion_enabled    = false
  internet_query_enabled        = false
  local_authentication_disabled = true

  monitoring = [
    {
      name                       = "diag"
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

- [ ] Disable public ingestion and query when private access is required
- [ ] Disable local authentication to enforce Azure AD
- [ ] Keep IP masking enabled unless explicitly required
- [ ] Restrict API key permissions and rotate regularly
- [ ] Configure diagnostic settings to a secure destination
- [ ] Apply least-privilege RBAC at the resource group and workspace levels

## Common Mistakes to Avoid

1. **Leaving public ingestion/query enabled in production**
2. **Disabling IP masking without a clear justification**
3. **Using overly permissive API key permissions**
4. **Skipping diagnostic settings configuration**

## Additional Resources

- Azure Application Insights documentation
- Azure Monitor diagnostic settings guidance

---

**Last Updated**: 2026-01-28
