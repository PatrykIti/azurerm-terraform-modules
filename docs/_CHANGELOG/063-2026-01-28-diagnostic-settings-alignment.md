# 063 - 2026-01-28 - Diagnostic settings alignment (AKS + Storage)

## Summary

Aligned diagnostic settings UX across AKS and Storage modules with a shared
`monitoring` schema, explicit category inputs, and consistent skip reporting.

## Changes

- Unified diagnostic settings inputs under `monitoring` for AKS and Storage,
  aligning with the shared module pattern and validation rules.
- Removed diagnostic category data sources and area-to-category mapping; users
  now provide explicit `log_categories` and/or `metric_categories`.
- Implemented per-scope monitoring for Storage (account/blob/queue/file/table/dfs)
  with global name uniqueness and per-scope limits.
- Updated diagnostics resources, skip outputs, and unit tests to reflect the
  new `monitoring` schema in both modules.

## Impact

- **Breaking change:** callers must migrate from `diagnostic_settings` to
  `monitoring` and supply explicit categories.
- Diagnostic settings behavior is consistent across AKS and Storage, with
  clearer validation and predictable skipping when categories are omitted.
