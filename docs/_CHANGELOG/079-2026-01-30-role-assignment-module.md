# 079 - 2026-01-30 - Role Assignment module

## Summary

Added the `azurerm_role_assignment` module for managing Azure RBAC role assignments,
including examples, tests, and security documentation.

## Changes

- Implemented `azurerm_role_assignment` with full RBAC inputs and preconditions.
- Added validation for mutually exclusive role definition inputs and ABAC conditions.
- Added basic/complete/secure and feature-specific examples.
- Added unit tests, integration fixtures, import guide, and security guidance.

## Impact

- New module only; no breaking changes to existing modules.
