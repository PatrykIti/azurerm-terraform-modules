# azurerm_managed_redis Module Security

## Overview

This document describes security considerations for the Azure Managed Redis
module. The module favors secure defaults where the provider allows them and
keeps cross-resource security wiring outside the module boundary.

## Security Features and Defaults

- **High availability enabled**: `managed_redis.high_availability_enabled` defaults to `true`.
- **Default database present**: The default database is created by default so the instance is usable immediately.
- **Access keys authentication disabled by default**: `default_database.access_keys_authentication_enabled` defaults to `false`.
- **Customer-managed key support**: `customer_managed_key` is supported with explicit user-assigned identity validation.
- **Diagnostic settings support**: Logs and metrics can be forwarded to Azure-native monitoring destinations.

## Hardening Guidance

1. **Disable public network access when not required**
   - Set `managed_redis.public_network_access = "Disabled"`.
   - Add private endpoints and DNS outside this module.

2. **Prefer CMK for regulated workloads**
   - Attach a user-assigned identity via `identity`.
   - Grant that identity `Get`, `WrapKey`, and `UnwrapKey` permissions on the Key Vault key.
   - Configure `customer_managed_key` with the same identity ID.

3. **Control diagnostic destinations**
   - Send diagnostics only to approved Log Analytics workspaces, Event Hubs, or Storage Accounts.
   - Apply least-privilege access to those destination resources.

4. **Review persistence carefully**
   - AOF/RDB persistence settings become part of Terraform state.
   - Restrict access to state storage and secret backends accordingly.

## Common Misconfigurations

- **Disabling public access but forgetting private connectivity outside the module**
  ```hcl
  managed_redis = {
    sku_name              = "Balanced_B3"
    public_network_access = "Disabled"
  }
  ```

- **Configuring CMK without a user-assigned identity**
  ```hcl
  customer_managed_key = {
    key_vault_key_id          = azurerm_key_vault_key.example.id
    user_assigned_identity_id = azurerm_user_assigned_identity.example.id
  }
  ```

- **Enabling persistence together with geo-replication**
  ```hcl
  default_database = {
    geo_replication_group_name                  = "prod-geo-group"
    persistence_redis_database_backup_frequency = "1h"
  }
  ```

## Operational Risks

- **Geo-replication linking/unlinking** can discard cache data and cause temporary outages.
- **Access keys**, when enabled, are exposed in Terraform state and module outputs are only marked sensitive, not removed from state.
- **CMK dependencies** can break updates if the user-assigned identity loses access to the Key Vault key.

## Additional References

- See [docs/README.md](docs/README.md) for scope and usage notes.
- See [docs/IMPORT.md](docs/IMPORT.md) for import guidance.
