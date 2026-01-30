# 066 - 2026-01-29 - Application Insights module fixes

## Summary

Aligned Application Insights module inputs and test fixtures with azurerm 4.57.0
schema and stabilized the test harness.

## Changes

- Adjusted classic and standard web test inputs to match provider schema
  (configuration argument, request/body/header, validation_rules).
- Normalized Application Insights resource labels in code to match guide naming
  and updated outputs accordingly.
- Updated fixtures/examples for tags variables, test logging, and workbook UUID
  requirements to ensure consistent test runs.

## Impact

- Early adopters using standard web test inputs should review validation_rules
  and request fields to match the current schema.
- Test runs now emit logs under `tests/test_outputs/` for easier debugging.
