# azurerm_redis_cache Module Security

## Overview

This document describes security considerations for the Azure Redis Cache module.
The module favors secure defaults (TLS 1.2, non-SSL port disabled) and requires
explicit opt-in for public exposure.

## Security Features and Defaults

- **TLS enforcement**: `minimum_tls_version` defaults to `1.2`.
- **Non-SSL port disabled**: `non_ssl_port_enabled` defaults to `false`.
- **Public access**: enabled by default to preserve backward compatibility; for
  private deployments, set `public_network_access_enabled = false` and use VNet
  injection (Premium SKU).
- **Managed identity**: optional system/user-assigned identity via `identity`.
- **Diagnostic settings**: configurable logging and metrics via
  `diagnostic_settings`.

## Hardening Guidance

1. **Prefer private access (Premium only)**
   - Set `public_network_access_enabled = false`.
   - Provide `subnet_id` and `private_static_ip_address` for VNet injection.

2. **Limit public access when required**
   - Keep `public_network_access_enabled = true` only when necessary.
   - Use `firewall_rules` to restrict IP ranges.

3. **Keep key-based access controlled**
   - If disabling access keys (`access_keys_authentication_enabled = false`),
     enable Azure AD authentication via
     `redis_configuration.active_directory_authentication_enabled`.

4. **Protect state files**
   - Redis persistence uses storage connection strings
     (`aof_storage_connection_string_*`, `rdb_storage_connection_string`). These
     values are stored in Terraform state and should be treated as secrets.
   - Outputs for connection strings and access keys are marked sensitive but
     still appear in state; restrict access to state storage.

## Common Misconfigurations

- **Enabling non-SSL port in production**
  ```hcl
  non_ssl_port_enabled = true
  ```
- **Disabling TLS 1.2**
  ```hcl
  minimum_tls_version = "1.0"
  ```
- **Leaving public access open without firewall rules**
  ```hcl
  public_network_access_enabled = true
  firewall_rules = []
  ```

## Additional References

- See `docs/README.md` for module scope and usage notes.
- See `docs/IMPORT.md` for import guidance.
