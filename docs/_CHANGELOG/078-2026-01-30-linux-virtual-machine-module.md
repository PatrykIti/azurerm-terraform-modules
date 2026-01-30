# 078 - 2026-01-30 - Linux Virtual Machine module

## Summary

Introduced the Linux Virtual Machine module with full VM coverage, extensions,
diagnostic settings, examples, and tests aligned to azurerm 4.57.0.

## Changes

- Added `modules/azurerm_linux_virtual_machine` with full VM inputs,
  validations, and outputs.
- Implemented VM extensions and diagnostic settings (including category
  discovery via `azurerm_monitor_diagnostic_categories`).
- Added examples and fixtures for basic/complete/secure and feature-specific
  scenarios, plus unit and Terratest coverage.
- Updated module documentation (README, IMPORT, SECURITY) and repo indexes.

## Impact

- New module available for consumption; no breaking changes to existing modules.
