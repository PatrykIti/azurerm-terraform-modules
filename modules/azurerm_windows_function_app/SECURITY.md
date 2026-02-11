# azurerm_windows_function_app Module Security

## Overview

This module manages Azure Windows Function Apps with secure defaults and optional hardening controls. It does not create private endpoints, private DNS, RBAC role assignments, service plans, storage accounts, or Application Insights resources. Those must be managed outside this module.

## Secure Defaults

- HTTPS-only enabled (`access_configuration.https_only = true`)
- Public network access disabled (`access_configuration.public_network_access_enabled = false`)
- FTP basic auth disabled (`access_configuration.ftp_publish_basic_authentication_enabled = false`)
- WebDeploy basic auth disabled (`access_configuration.webdeploy_publish_basic_authentication_enabled = false`)

## Supported Security Controls

- **TLS hardening**: `site_config.minimum_tls_version` and `site_config.scm_minimum_tls_version`
- **Client certificates**: `access_configuration.client_certificate_enabled` and `access_configuration.client_certificate_mode`
- **IP restrictions**: `site_config.ip_restriction` + `ip_restriction_default_action`
- **SCM IP restrictions**: `site_config.scm_ip_restriction` + `scm_ip_restriction_default_action`
- **Managed identity**: `identity` for platform access
- **Storage access**: `storage_configuration.uses_managed_identity` or `storage_configuration.key_vault_secret_id`
- **Audit telemetry**: `diagnostic_settings` to Log Analytics, Storage, or Event Hub

## Security Considerations

- App settings and connection strings may include secrets. Prefer Key Vault references and avoid storing secrets in plain text variables.
- `storage_configuration.key_vault_secret_id` without a version uses the latest secret version, but propagation can take up to 24 hours after rotation.
- Enabling public network access exposes the app to the internet; combine it with IP restrictions if required.

## Secure Configuration Example

```hcl
module "windows_function_app" {
  source = "../../"

  name                = "wfunc-secure"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  service_plan_id     = azurerm_service_plan.example.id

  storage_configuration = {
    account_name       = azurerm_storage_account.example.name
    account_access_key = azurerm_storage_account.example.primary_access_key
  }

  access_configuration = {
    https_only                                 = true
    public_network_access_enabled              = false
    ftp_publish_basic_authentication_enabled   = false
    webdeploy_publish_basic_authentication_enabled = false
  }

  identity = {
    type = "SystemAssigned"
  }

  site_config = {
    minimum_tls_version     = "1.2"
    scm_minimum_tls_version = "1.2"
    ip_restriction_default_action = "Deny"
    application_stack = {
      dotnet_version = "v8.0"
    }
  }
}
```

## Security Checklist

- [ ] Set `site_config.minimum_tls_version` and `site_config.scm_minimum_tls_version` to 1.2 or higher.
- [ ] Keep `access_configuration.public_network_access_enabled = false` unless explicitly required.
- [ ] Disable FTP/WebDeploy basic auth unless required.
- [ ] Use managed identity for storage access or a Key Vault secret ID.
- [ ] Configure IP restrictions for app and SCM endpoints.
- [ ] Enable diagnostic settings to a secure destination.
- [ ] Review app settings for secrets and move them to Key Vault references.
