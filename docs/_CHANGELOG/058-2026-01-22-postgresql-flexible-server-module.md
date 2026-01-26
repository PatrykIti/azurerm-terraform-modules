# 058 - 2026-01-22 - PostgreSQL Flexible Server module (full feature scope)

## Summary

Added a new `modules/azurerm_postgresql_flexible_server` module with server-scoped
resources, diagnostics, examples, and test coverage aligned to repo standards.

## Changes

- Implemented PostgreSQL Flexible Server with full server feature support.
- Added configurations, firewall rules, Entra ID admin, virtual endpoints, and backups.
- Added diagnostic settings with category filtering and skipped output reporting.
- Created basic, complete, secure, and feature-specific examples.
- Added unit, integration, and performance tests with updated fixtures.
- Documented scope, import guidance, and security hardening.

## Impact

- New AzureRM module: `azurerm_postgresql_flexible_server`.
- PostgreSQL databases remain out of scope (separate module).
