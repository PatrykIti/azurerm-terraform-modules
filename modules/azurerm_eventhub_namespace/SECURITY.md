# Event Hub Namespace Security Guidance

## Security posture

- **Network access**: Set `public_network_access_enabled = false` and use a private endpoint for private-only access.
- **Authentication**: Disable SAS by setting `local_authentication_enabled = false` when using Entra ID (AAD).
- **TLS**: Keep `minimum_tls_version = "1.2"`.
- **CMK**: Use `customer_managed_key` with a managed identity and Key Vault permissions.

## Secure configuration example

```hcl
module "eventhub_namespace" {
  source = ".../modules/azurerm_eventhub_namespace"

  name                = "ehns-secure"
  resource_group_name = "rg-secure"
  location            = "westeurope"
  sku                 = "Standard"

  public_network_access_enabled = false
  local_authentication_enabled  = false

  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.cmk.id]
  }

  customer_managed_key = {
    key_vault_key_ids         = [azurerm_key_vault_key.example.id]
    user_assigned_identity_id = azurerm_user_assigned_identity.cmk.id
  }
}
```

## Checklist

- [ ] Public network access disabled (unless explicitly required).
- [ ] SAS authentication disabled for AAD-only scenarios.
- [ ] CMK configured with Key Vault access policies.
- [ ] Diagnostic settings enabled for audit/operational logs.

## Common pitfalls

- **CMK without identity**: The namespace must have the managed identity assigned.
- **Network rule mismatch**: `network_rule_set.public_network_access_enabled` must match the namespace setting.
- **Missing diagnostics**: Omit diagnostic settings only if monitoring is handled elsewhere.
