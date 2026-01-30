# Windows Function App Module

## Overview

This module manages a single Azure Windows Function App with optional slots and diagnostic settings. It is designed for atomic usage and composes with other modules for service plans, storage accounts, and observability resources.

## Managed Resources

- `azurerm_windows_function_app`
- `azurerm_windows_function_app_slot` (optional)
- `azurerm_monitor_diagnostic_setting` (optional)

## Usage Notes

- `site_config` is required and must include an `application_stack` with exactly one runtime.
- Storage must be configured using either:
  - `storage_account_name` + `storage_account_access_key`, or
  - `storage_account_name` + `storage_uses_managed_identity` (with `identity`), or
  - `storage_key_vault_secret_id` (without `storage_account_name`).
- `auth_settings` and `auth_settings_v2` are mutually exclusive.
- Slots require their own `site_config` and can inherit storage settings from the main app or override them.
- Diagnostic settings support `areas = ["all"]`, `areas = ["logs"]`, or `areas = ["metrics"]` to auto-select categories.

## Out of Scope

- App Service Plan (`azurerm_service_plan` / `azurerm_app_service_plan`)
- Storage Account (`azurerm_storage_account`)
- Application Insights (`azurerm_application_insights`)
- Private endpoints, Private DNS, and other network glue
- RBAC/role assignments, Key Vault, budgets, alerts
- Custom hostname bindings and certificates
