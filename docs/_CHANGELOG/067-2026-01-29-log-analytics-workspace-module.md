# 067 - 2026-01-29 - Log Analytics Workspace module

## Summary

Introduced the Log Analytics Workspace module with full workspace coverage,
workspace-linked sub-resources, diagnostics, examples, and tests aligned to
azurerm 4.57.0.

## Changes

- Added `modules/azurerm_log_analytics_workspace` with core workspace inputs,
  validations, and outputs.
- Implemented workspace-linked sub-resources (solutions, data export rules,
  data sources, storage insights, linked services, dedicated clusters, CMK).
- Added diagnostic settings support via `monitoring` inputs.
- Added examples and fixtures for basic/complete/secure and feature-specific
  scenarios, plus unit and Terratest coverage.
- Updated module documentation (README, IMPORT, SECURITY) and test harness
  scripts to match repo conventions.

## Impact

- New module available for consumption; no breaking changes to existing modules.
