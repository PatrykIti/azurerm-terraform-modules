# azurerm_postgresql_flexible_server Module Security

## Overview

This document describes the security controls supported by the
`azurerm_postgresql_flexible_server` module and recommended hardening options.

## Security Features

### 1) Network Isolation

- **Private access**: Set `network.public_network_access_enabled = false`.
  For delegated subnet private access, supply `network.delegated_subnet_id` plus
  `network.private_dns_zone_id`. You can also disable public access and attach
  a private endpoint outside this module.
- **Firewall rules**: When public access is enabled, restrict inbound access via
  `network.firewall_rules` using explicit allow-list IP ranges.

### 2) Authentication and Identity

- **Password authentication**: Enabled by default; provide secure credentials.
- **Microsoft Entra ID (Azure AD)**: Enable with
  `authentication.active_directory_auth_enabled = true` and configure
  `active_directory_administrator`.
- **Managed identity**: Supports system and user-assigned identities to access
  external services (for example, Key Vault for CMK).

### 3) Customer-Managed Keys (CMK)

- **BYOK support**: Configure `server.encryption` with a Key Vault key URL.
- **User-assigned identity required**: The identity must have access to the key.

### 4) Backup and Resilience

- **Retention**: `server.backup.retention_days` supports 7-35 days.
- **Geo-redundant backups**: Enable with `server.backup.geo_redundant_backup_enabled`.

### 5) Monitoring and Auditing

- **Diagnostic settings**: Stream logs and metrics to Log Analytics, Storage, or
  Event Hub with `monitoring`.

## Secure Configuration Example

A hardened deployment is provided in `examples/secure`, which includes:
- Private networking (delegated subnet + private DNS zone)
- Entra ID authentication
- Customer-managed key encryption
- Geo-redundant backups

## Security Hardening Checklist

Before deploying to production:

- [ ] Disable public network access or restrict firewall rules to known IPs
- [ ] Enable Entra ID authentication and configure an admin principal
- [ ] Use a strong administrator password and rotate regularly
- [ ] Enable CMK encryption where required
- [ ] Configure diagnostic settings and retain logs centrally
- [ ] Set backup retention and geo-redundant backups according to policy

## Common Security Mistakes to Avoid

1) **Public access without firewall rules**
   ```hcl
   # Avoid leaving public access open with no firewall rules
   network = {
     public_network_access_enabled = true
   }
   ```

2) **Entra ID auth without admin**
   ```hcl
   # Avoid enabling AAD without active_directory_administrator
   authentication = {
     active_directory_auth_enabled = true
   }
   ```

3) **CMK without identity access**
   ```hcl
   # Avoid setting CMK without a user-assigned identity
   server = {
     encryption = {
       key_vault_key_id = "https://.../keys/key/version"
     }
   }
   ```

---

**Module Version**: vUnreleased
