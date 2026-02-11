# 074 - 2026-01-30 - Linux Function App module

## Summary

Introduced the `azurerm_linux_function_app` module with full Linux Function App
feature coverage, slots support, and inline diagnostic settings.

## Changes

- Added `modules/azurerm_linux_function_app` with full provider schema coverage.
- Implemented slots support and inline diagnostic settings.
- Added examples: basic, complete, secure, slots, auth-settings-v2, zip-deploy.
- Added module documentation: README, SECURITY, and IMPORT guides.
- Added unit tests and refreshed Terratest fixtures.

## Impact

- New module only; no breaking changes.
