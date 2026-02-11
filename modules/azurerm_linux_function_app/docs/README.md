# Linux Function App Module Documentation

## Overview

This module provisions an Azure Linux Function App with optional slots and inline
monitoring diagnostic settings. It focuses on a single primary Function App and
keeps cross-resource glue (service plan, storage account, application insights,
private endpoints, RBAC, networking glue) outside the module.

## Managed Resources

- `azurerm_linux_function_app`
- `azurerm_linux_function_app_slot` (optional)
- `azurerm_monitor_diagnostic_setting` (optional, inline diagnostics)

## Usage Notes

- **Service plan is required**: Provide a Linux App Service Plan ID via
  `service_plan_id`.
- **Storage is required**: Configure `storage_configuration.account_name` and either
  `storage_configuration.account_access_key` or set
  `storage_configuration.uses_managed_identity = true` with a managed identity.
- **Runtime stack required**: `site_configuration.application_stack` must specify
  exactly one runtime (Docker or a single language runtime).
- **Authentication**: `auth_settings` and `auth_settings_v2` are mutually
  exclusive for both the primary app and slots.
- **Diagnostics**: Use `diagnostic_settings` to route logs/metrics to Log
  Analytics, Storage, or Event Hub.

## Out of Scope (by design)

- App Service Plan creation (`azurerm_service_plan`)
- Storage Account creation (`azurerm_storage_account`)
- Application Insights (`azurerm_application_insights`)
- Private Endpoints / Private DNS / VNet glue
- Role assignments / RBAC / Key Vault
- Budgeting, alerts, and policy assignments
- Custom hostname bindings and certificates

## Additional Docs

- [IMPORT.md](./IMPORT.md) - Importing existing Function Apps
- [SECURITY.md](../SECURITY.md) - Security hardening guidance
