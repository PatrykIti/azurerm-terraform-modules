# azurerm_linux_function_app Module Security

## Overview

This document summarizes the security posture and hardening guidance for the
Linux Function App module. The module is **security-first** by default and
exposes additional controls for authentication, networking, and monitoring.

## Security Defaults

- **HTTPS-only**: `https_only = true` by default.
- **TLS minimum**: `site_config.minimum_tls_version` supports 1.2/1.3 (set to
  1.2 in secure examples).
- **Public access**: `public_network_access_enabled = false` by default.
- **FTP basic auth**: `ftp_publish_basic_authentication_enabled = false` by default.

## Key Security Controls

### Authentication & Authorization
- `auth_settings` (v1) or `auth_settings_v2` (v2) enable provider-backed auth.
- Use `default_provider` and `unauthenticated_action` to enforce login.
- Prefer `auth_settings_v2` for modern flows and managed secrets.

### Identity & Secrets
- Use **Managed Identity** for storage access with `storage_uses_managed_identity = true`.
- Store secrets in Key Vault and reference them via app settings where possible.

### Network Restrictions
- Use `site_config.ip_restriction` and `site_config.scm_ip_restriction` to
  allow only approved IP ranges, service tags, or subnets.
- Set default action to `Deny` when restricting inbound access.

### Monitoring & Auditing
- Enable `diagnostic_settings` to route logs/metrics to Log Analytics, Storage,
  or Event Hub.
- Ensure diagnostics retention aligns with compliance requirements.

## Secure Configuration Example

```hcl
module "linux_function_app" {
  source = "./modules/azurerm_linux_function_app"

  name                = "func-secure"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id

  storage_account_name        = azurerm_storage_account.main.name
  storage_uses_managed_identity = true

  identity = {
    type = "SystemAssigned"
  }

  https_only                    = true
  public_network_access_enabled = false

  site_config = {
    minimum_tls_version = "1.2"
    scm_minimum_tls_version = "1.2"
    ip_restriction_default_action = "Deny"
    scm_ip_restriction_default_action = "Deny"
    application_stack = {
      node_version = "20"
    }
  }

  diagnostic_settings = [
    {
      name                       = "diag"
      log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
      areas                      = ["all"]
    }
  ]

  tags = {
    Environment = "Production"
  }
}
```

## Security Checklist

- [ ] Enforce HTTPS-only and TLS 1.2+.
- [ ] Disable public network access unless explicitly required.
- [ ] Configure IP restrictions for app and SCM endpoints.
- [ ] Use managed identity for storage and external dependencies.
- [ ] Enable diagnostics and monitor logs/metrics centrally.
- [ ] Avoid secrets in plain text app settings.
