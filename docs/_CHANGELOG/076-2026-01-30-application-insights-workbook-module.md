# 076 - 2026-01-30 - Application Insights Workbook module

## Summary

Added the `azurerm_application_insights_workbook` module with full workbook
feature coverage, documentation, examples, and tests.

## Changes

- Introduced the new workbook module with identity, source ID, and timeouts
  support.
- Added basic/complete/secure examples plus identity/source-id examples.
- Added unit tests, terratest fixtures, and integration coverage.
- Documented import guidance and security considerations.

## Impact

- New module only; no breaking changes to existing modules.
