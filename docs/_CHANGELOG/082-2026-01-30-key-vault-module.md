# 082 - 2026-01-30 - Key Vault module

## Summary

Introduced the Azure Key Vault module with full data-plane coverage, diagnostics,
examples, and tests aligned to azurerm 4.57.0.

## Changes

- Added `modules/azurerm_key_vault` with Key Vault, access policies, keys,
  secrets, certificates, certificate issuers, managed storage accounts, SAS
  definitions, and diagnostic settings.
- Implemented secure defaults, cross-field validations, and detailed outputs.
- Added examples for basic/complete/secure plus feature-specific scenarios.
- Added unit tests, fixtures, and Terratest coverage.
- Added module documentation including SECURITY and import guidance.

## Impact

- New module available for consumption; no breaking changes to existing modules.
