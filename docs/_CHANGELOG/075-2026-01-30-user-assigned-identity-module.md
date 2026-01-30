# 075 - 2026-01-30 - User Assigned Identity module

## Summary

Introduced the User Assigned Identity module with support for federated identity
credentials, examples, documentation, and tests aligned to azurerm 4.57.0.

## Changes

- Added `modules/azurerm_user_assigned_identity` with core UAI inputs, validations,
  timeouts, and outputs.
- Implemented federated identity credentials support via `federated_identity_credentials`.
- Added examples for basic/complete/secure plus federated-identity-credentials and
  GitHub Actions OIDC usage.
- Added unit tests, Terratest fixtures, and integration/performance coverage.
- Added module documentation including SECURITY and import guidance.

## Impact

- New module available for consumption; no breaking changes to existing modules.
