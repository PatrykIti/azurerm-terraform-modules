# 065 - 2026-01-28 - Application Insights module

## Summary

Added a full-featured Application Insights module with core resource support,
sub-resources, diagnostics, examples, and test coverage.

## Changes

- Added `modules/azurerm_application_insights` module scaffold and core
  implementation for Application Insights.
- Implemented sub-resources: API keys, analytics items, classic and standard
  web tests, workbooks, and smart detection rules.
- Added diagnostic settings support using the shared `monitoring` schema.
- Created examples (basic/complete/secure + feature-specific) and fixtures.
- Updated unit tests, terratest fixtures, and documentation.

## Impact

- Enables atomic management of Application Insights with consistent patterns
  across the repo and secure defaults.
- Supports optional sub-resources and diagnostics without bundling networking
  or RBAC glue.
