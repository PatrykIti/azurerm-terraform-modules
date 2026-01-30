# 080 - 2026-01-30 - Role Definition module

## Summary

Added the `azurerm_role_definition` module for managing custom Azure RBAC roles,
including examples, tests, and security documentation.

## Changes

- Implemented `azurerm_role_definition` with permissions, assignable scopes, and timeouts.
- Added validations for permissions structure and scope relationships.
- Added basic/complete/secure examples and test fixtures.
- Added module documentation, import guide, and security guidance.

## Impact

- New module only; no breaking changes to existing modules.
