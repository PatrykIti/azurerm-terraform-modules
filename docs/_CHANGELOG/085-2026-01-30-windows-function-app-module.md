# Azure Windows Function App module

**Date:** 2026-01-30

## Summary

Introduced the `azurerm_windows_function_app` module with full Windows Function App coverage, including slots, diagnostics, auth settings, storage options, and secure defaults. The module ships with basic/complete/secure examples and updated tests aligned with repository standards.

## Scope

- New module: `modules/azurerm_windows_function_app`
- Slot support via `azurerm_windows_function_app_slot`
- Diagnostic settings with category discovery and area mapping
- Storage options: access key, managed identity, or Key Vault secret
- Examples: basic, complete, secure
- Unit and integration test fixtures

## Notes

Service plans, storage accounts, Application Insights, private endpoints, RBAC, and DNS/network glue remain out-of-scope and should be composed via dedicated modules or higher-level stacks.
