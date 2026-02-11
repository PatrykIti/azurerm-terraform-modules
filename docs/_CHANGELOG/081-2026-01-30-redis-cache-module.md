# 081 - 2026-01-30 - Redis Cache module

## Summary

Introduced the Azure Redis Cache module with full feature coverage, diagnostics,
examples, and tests aligned to azurerm 4.57.0.

## Changes

- Added `modules/azurerm_redis_cache` with core Redis Cache resource, patch
  schedule, firewall rules, linked servers, and diagnostic settings support.
- Implemented secure defaults, cross-field validations, and detailed outputs.
- Added examples for basic/complete/secure plus feature-specific scenarios.
- Added unit tests, fixtures, and Terratest coverage for key configurations.
- Added module documentation including SECURITY and import guidance.

## Impact

- New module available for consumption; no breaking changes to existing modules.
