# 069 - 2026-01-29 - DCR association support

## Summary

Added Data Collection Rule association support to the DCR module and updated AKS
examples to use the new input.

## Changes

- Added `associations` input and association resource creation in
  `azurerm_monitor_data_collection_rule`.
- Exposed association outputs for downstream usage.
- Updated AKS examples to configure associations via the module input.
- Updated module documentation and import guidance.

## Impact

- New optional input only; existing configurations remain compatible.
