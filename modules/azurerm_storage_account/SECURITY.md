# Storage Account Module Security

## Overview

This document summarizes the security posture of the Azure Storage Account module. The module applies security-by-default settings while allowing explicit opt-in for less restrictive configurations.

## Security Features

### 1) Encryption
- **Infrastructure encryption**: `encryption.infrastructure_encryption_enabled` (default: `true`)
- **Customer-managed keys (CMK)**: `encryption.key_vault_key_id` + `encryption.user_assigned_identity_id`
- **TLS**: `security_settings.min_tls_version` (default: `TLS1_2`)

### 2) Access Control
- **Shared access keys disabled** by default: `security_settings.shared_access_key_enabled = false`
- **OAuth by default** (optional): `default_to_oauth_authentication = true`

### 3) Network Isolation
- **Default deny** network rules (when configured): `network_rules.default_action = "Deny"`
- **Private endpoints** for each storage service (blob/queue/file/table)

### 4) Monitoring & Diagnostics
- **Diagnostic settings** managed by the module with per-scope selection:
  - `storage_account`, `blob`, `queue`, `file`, `table`, `dfs`
- Categories are **filtered** against what Azure exposes in the target region/scope.
  Entries that resolve to **no categories** are skipped and listed in `diagnostic_settings_skipped`.

## Secure Configuration Example

```hcl
module "storage_account" {
  source = "../.."

  name                = "stsecureexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  security_settings = {
    https_traffic_only_enabled      = true
    min_tls_version                 = "TLS1_2"
    shared_access_key_enabled       = false
    allow_nested_items_to_be_public = false
    public_network_access_enabled   = false
  }

  encryption = {
    enabled                           = true
    infrastructure_encryption_enabled = true
    key_vault_key_id                  = azurerm_key_vault_key.storage.id
    user_assigned_identity_id         = azurerm_user_assigned_identity.storage.id
  }

  network_rules = {
    bypass                     = []
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }

  diagnostic_settings = [
    {
      name                       = "diag-storage"
      scope                      = "storage_account"
      areas                      = ["transaction", "capacity"]
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    },
    {
      name                       = "diag-blob"
      scope                      = "blob"
      areas                      = ["read", "write", "delete", "transaction", "capacity"]
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    }
  ]
}
```

## Security Hardening Checklist

- [ ] HTTPS only enabled (`https_traffic_only_enabled = true`)
- [ ] TLS 1.2 minimum
- [ ] Shared access keys disabled
- [ ] Public network access disabled where possible
- [ ] Network rules default to Deny
- [ ] Private endpoints configured for used services
- [ ] CMK enabled where required
- [ ] Diagnostic settings enabled for required scopes
- [ ] Tags applied for compliance/ownership

## Common Security Mistakes to Avoid

1. **Allowing public access**
   ```hcl
   # ❌ AVOID
   security_settings = {
     public_network_access_enabled = true
   }
   ```

2. **Enabling shared access keys**
   ```hcl
   # ❌ AVOID
   security_settings = {
     shared_access_key_enabled = true
   }
   ```

3. **Disabling HTTPS**
   ```hcl
   # ❌ NEVER DO THIS
   security_settings = {
     https_traffic_only_enabled = false
   }
   ```

4. **Using legacy TLS versions**
   ```hcl
   # ❌ AVOID
   security_settings = {
     min_tls_version = "TLS1_0"
   }
   ```
