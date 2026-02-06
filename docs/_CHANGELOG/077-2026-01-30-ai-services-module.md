# 077 - 2026-01-30 - AI Services module

## Summary

Added the `azurerm_ai_services` module based on the AzureRM
`azurerm_ai_services` resource, including diagnostics support, security docs,
examples, and tests.

## Changes

- Implemented AI Services Account resource with identity, CMK, network ACLs,
  storage blocks, and timeouts.
- Added diagnostic settings with category discovery and `areas` mapping.
- Added basic/complete/secure examples plus test fixtures.
- Added module documentation, import guide, and security guidance.

## Impact

- New module only; no breaking changes to existing modules.
