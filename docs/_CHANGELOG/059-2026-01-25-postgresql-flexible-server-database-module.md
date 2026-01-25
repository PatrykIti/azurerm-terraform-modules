# 059 - 2026-01-25 - PostgreSQL Flexible Server Database module

## Summary

Added a new `modules/azurerm_postgresql_flexible_server_database` module for
managing databases on an existing PostgreSQL Flexible Server.

## Changes

- Implemented the database resource with grouped inputs and validations.
- Added basic, complete, and secure examples with updated fixtures and tests.
- Documented usage, import guidance, and security notes.

## Impact

- New AzureRM module: `azurerm_postgresql_flexible_server_database`.
