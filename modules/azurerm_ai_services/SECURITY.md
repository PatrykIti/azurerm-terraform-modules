# azurerm_ai_services Module Security

## Overview

This document describes the security-relevant configuration options exposed by the
azurerm_ai_services module and how to use them to harden Azure AI Services
Accounts.

## Security Features

### Authentication and Access
- **Local authentication**: `local_authentication_enabled` controls local auth access keys. Disable for tighter security.
- **Managed identities**: `identity` supports SystemAssigned, UserAssigned, or both for Azure AD-based access.
- **Customer-managed keys**: `customer_managed_key` enables CMK encryption when a user-assigned identity is configured.

### Network Controls
- **Public access**: `public_network_access` can be set to `Disabled` to prevent public access.
- **Network ACLs**: `network_acls` allows IP and VNet restrictions. `custom_subdomain_name` is required when using ACLs.
- **Allowed FQDNs**: `fqdns` can be used to restrict allowed endpoints.

### Monitoring
- **Diagnostic settings**: `diagnostic_settings` supports routing logs/metrics to Log Analytics, Storage, or Event Hub.

### Out-of-scope Controls
- **Private endpoints**: Not managed by this module; use the dedicated private endpoint module.
- **RBAC/role assignments**: Not managed by this module; use the role assignment module.

## Secure Configuration Example

```hcl
resource "azurerm_user_assigned_identity" "ai" {
  name                = "id-ai-secure-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_key_vault_key" "ai" {
  name         = "ai-services-key"
  key_vault_id = azurerm_key_vault.example.id
  key_type     = "RSA"
  key_size     = 2048
}

module "ai_services" {
  source = "../../"

  name                = "aiservices-secure-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_name            = "S0"

  public_network_access        = "Disabled"
  local_authentication_enabled = false

  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.ai.id]
  }

  customer_managed_key = {
    key_vault_key_id  = azurerm_key_vault_key.ai.id
    identity_client_id = azurerm_user_assigned_identity.ai.client_id
  }

  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = []
  }

  custom_subdomain_name = "aiservices-secure-example"

  diagnostic_settings = [{
    name                       = "ai-services-audit"
    log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    log_categories             = ["Audit"]
    metric_categories          = ["AllMetrics"]
  }]
}
```

## Security Hardening Checklist

- [ ] Disable local authentication if not required.
- [ ] Disable public network access where private connectivity is used.
- [ ] Use `network_acls` to restrict access and set `default_action = "Deny"`.
- [ ] Enable CMK encryption with a user-assigned identity.
- [ ] Enable diagnostic settings and route to Log Analytics.
- [ ] Use RBAC to scope access to the AI Services Account.

## Common Mistakes to Avoid

1. **Leaving local authentication enabled**
   ```hcl
   # ❌ Avoid for production unless required
   local_authentication_enabled = true
   ```

2. **Allowing public access without restrictions**
   ```hcl
   # ❌ Avoid unless you explicitly need public access
   public_network_access = "Enabled"
   ```

3. **Missing custom_subdomain_name when using ACLs**
   ```hcl
   # ❌ Invalid: network_acls requires custom_subdomain_name
   network_acls = { default_action = "Deny" }
   ```

## References

- Azure AI Services security guidance
- Azure Key Vault and Managed HSM documentation
- Azure Monitor diagnostic settings documentation
