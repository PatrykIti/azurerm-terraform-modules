# 068 - 2026-01-29 - Log Analytics Workspace module inputs refactor

## Summary

Refactored Log Analytics Workspace module inputs into grouped objects to improve
readability and align with repository conventions.

## Changes

- Introduced `workspace` and `features` input objects to group core settings and
  workspace-linked resources.
- Updated module implementation, examples, fixtures, and unit tests to use the
  new input structure.
- Regenerated module documentation to reflect the new input layout.

## Impact

- **Breaking:** Consumers must migrate from flat inputs (e.g. `sku`,
  `retention_in_days`, `solutions`) to `workspace` and `features` objects.
- Existing module functionality remains the same once inputs are updated.
