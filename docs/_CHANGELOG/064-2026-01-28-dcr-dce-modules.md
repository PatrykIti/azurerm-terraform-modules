# 064 - 2026-01-28 - Azure Monitor DCR + DCE modules

## Summary

Added dedicated modules for Azure Monitor Data Collection Rules (DCR) and Data
Collection Endpoints (DCE) with full scaffolding, documentation, examples, and
unit/integration test coverage.

## Changes

- Introduced `modules/azurerm_monitor_data_collection_rule` and
  `modules/azurerm_monitor_data_collection_endpoint` with full repo-standard
  structure, versioning, and release metadata.
- Implemented core resources, inputs, validations, and outputs for DCR and DCE,
  including optional diagnostic settings via the shared `monitoring` schema.
- Added runnable examples (basic/complete/secure and feature-specific), test
  fixtures, and terratest/unit coverage for both modules.
- Documented module usage, imports, and security considerations.

## Impact

- Enables atomic management of DCR and DCE resources with consistent patterns
  across the repo and secure defaults.
- Supports composition with external networking/RBAC and AMPLS modules without
  cross-resource coupling.
