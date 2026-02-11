# azurerm_cognitive_account Module Security

## Overview

This module exposes security controls for Azure Cognitive Services accounts with a focus on OpenAI, Language (TextAnalytics), and Speech workloads.

## Security Controls

### Network Access
- **Public access**: Disable with `public_network_access_enabled = false` to require private access.
- **Network ACLs**: Use `network_acls` to restrict inbound access by IP and subnet. When enabled, `custom_subdomain_name` is required.
- **Private endpoints**: Not managed by this module. If you create a private endpoint separately, ensure `custom_subdomain_name` is set and configure private DNS zones.

### Authentication
- **Local authentication**: Disable shared keys by setting `local_auth_enabled = false`.
- **Managed identity**: Use system/user-assigned identities for Entra ID authentication and CMK access.

### Encryption (Customer-Managed Keys)
- Configure `customer_managed_key` to use a Key Vault key for encryption at rest.
- CMK requires a user-assigned identity that has access to the key.
- Manage CMK inline (default) or with the separate resource using `use_separate_resource = true`.

### Monitoring
- Configure `diagnostic_settings` to ship logs and metrics to Log Analytics, Storage, or Event Hub.

## Secure Example

```hcl
module "cognitive_account" {
  source = "./modules/azurerm_cognitive_account"

  name                = "example-openai-secure"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind     = "OpenAI"
  sku_name = "S0"

  public_network_access_enabled = false
  local_auth_enabled            = false
  custom_subdomain_name         = "example-openai-secure"

  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.example.id]
  }

  customer_managed_key = {
    key_vault_key_id      = azurerm_key_vault_key.example.id
    identity_client_id    = azurerm_user_assigned_identity.example.client_id
    use_separate_resource = true
  }

  diagnostic_settings = [
    {
      name                       = "diag"
      log_category_groups        = ["allLogs"]
      metric_categories          = ["AllMetrics"]
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    }
  ]

  tags = {
    Environment = "Production"
    Service     = "OpenAI"
  }
}
```

## Common Misconfigurations

1. **Public access enabled without restrictions**
   - Ensure `public_network_access_enabled` is disabled or restrict access via `network_acls`.

2. **CMK without user-assigned identity**
   - CMK requires a user-assigned identity. Configure `identity` accordingly.

3. **Missing custom subdomain for private access**
   - `custom_subdomain_name` is required when `network_acls` is set and for private endpoints.

4. **Local auth enabled in production**
   - Disable local auth (`local_auth_enabled = false`) to enforce Entra ID authentication.

## Security Checklist

- [ ] Disable public network access where possible
- [ ] Configure network ACLs or private endpoints
- [ ] Disable local auth if Entra ID is required
- [ ] Enable CMK for encryption at rest
- [ ] Enable diagnostic settings for logs and metrics
- [ ] Apply least-privilege RBAC outside the module
