# azurerm_key_vault Module Security

## Overview

This document outlines security-relevant configuration for the Key Vault module.
The module manages the Key Vault resource and optional data-plane resources.
Networking glue (private endpoints, Private DNS) and RBAC role assignments are
**out of scope** and must be managed externally.

## Security Features in This Module

### RBAC vs Access Policies
- `rbac_authorization_enabled = true` enables RBAC-only authorization.
- When RBAC is enabled, `access_policies` must be empty.
- When RBAC is disabled, define `access_policies` with least-privilege permissions.

### Public Network Access
- `public_network_access_enabled` controls public ingress.
- For production workloads, disable public access and use private endpoints.
- When public access is enabled, use `network_acls` to restrict sources.

### Soft Delete and Purge Protection
- `soft_delete_retention_days` controls the recovery window (7-90 days).
- `purge_protection_enabled = true` prevents permanent deletion and is recommended.

### Secrets, Keys, and Certificates
- Secrets can be provided as write-only values (`value_wo`) to avoid state exposure.
- Keys and certificates support rotation policies; align schedules with your security policy.
- Treat storage account keys and issuer credentials as sensitive inputs.

### Diagnostic Settings
- `diagnostic_settings` supports Log Analytics, Storage, Event Hub, or partner solutions.
- Configure categories explicitly (`log_categories`, `metric_categories`, `log_category_groups`).

## Example: Security-Focused Configuration

```hcl
module "key_vault" {
  source = "./modules/azurerm_key_vault"

  name                = "kv-secure"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  rbac_authorization_enabled   = true
  public_network_access_enabled = false
  purge_protection_enabled     = true

  network_acls = {
    bypass         = "None"
    default_action = "Deny"
  }

  diagnostic_settings = [
    {
      name                       = "diag"
      log_analytics_workspace_id = azurerm_log_analytics_workspace.audit.id
      log_category_groups        = ["allLogs"]
      metric_categories          = ["AllMetrics"]
    }
  ]

  tags = {
    Environment        = "Production"
    DataClassification = "Confidential"
  }
}
```

## Security Hardening Checklist

- [ ] Use RBAC or least-privilege access policies (not both)
- [ ] Disable public network access where possible
- [ ] Configure private endpoints and Private DNS externally
- [ ] Enable purge protection and set appropriate retention
- [ ] Enable diagnostic settings to a secure destination
- [ ] Rotate keys/secrets and store credentials securely

## Common Mistakes to Avoid

1. Leaving public access enabled in production.
2. Granting broad permissions in access policies.
3. Disabling purge protection without a recovery plan.
4. Storing storage account keys in source control.

---

**Last Updated**: 2026-01-30
