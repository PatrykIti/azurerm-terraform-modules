# TASK-048: Log Analytics Workspace Diagnostic Settings Input Alignment

**Priority:** High  
**Category:** Compliance / Audit Remediation  
**Estimated Effort:** Medium  
**Module:** `modules/azurerm_log_analytics_workspace`  
**Status:** ✅ Done (2026-02-08)

---

## Overview

Align diagnostics input modeling and validations in `azurerm_log_analytics_workspace` with checklist expectations from:

- `docs/MODULE_GUIDE/10-checklist.md`
- `docs/MODULE_GUIDE/11-scope-and-provider-coverage-status-check.md`

This task focuses on replacing legacy diagnostics input naming and tightening validation behavior to deterministic, explicit diagnostics semantics.

## Current Gaps

1. Diagnostics input still uses `monitoring` instead of `diagnostic_settings`.
2. Input schema misses `log_category_groups`.
3. Diagnostics validation does not enforce pinned allow-lists for categories/category groups/metrics.
4. Module docs and unit tests still reflect legacy diagnostics input naming.

## Scope

### In scope

- `modules/azurerm_log_analytics_workspace/variables.tf`
- `modules/azurerm_log_analytics_workspace/diagnostics.tf`
- `modules/azurerm_log_analytics_workspace/outputs.tf`
- module examples using diagnostics input
- module docs and unit tests affected by diagnostics input rename

### Out of scope

- Breaking module split for non-primary workspace-adjacent resources (tracked separately in TASK-044).

## Docs to Update

### In-module

- `modules/azurerm_log_analytics_workspace/README.md`
- `modules/azurerm_log_analytics_workspace/docs/README.md`
- `modules/azurerm_log_analytics_workspace/docs/IMPORT.md` (if diagnostics input examples are referenced)
- `modules/azurerm_log_analytics_workspace/SECURITY.md`

### Outside module

- `docs/_TASKS/README.md`

## Acceptance Criteria

1. Diagnostics input is exposed as `diagnostic_settings` (no `monitoring` input remains).
2. `diagnostic_settings` supports `log_categories`, `log_category_groups`, and `metric_categories`.
3. Validation enforces:
- non-empty names and destination IDs,
- destination consistency rules,
- at least one category/group/metric,
- pinned allow-lists for category fields.
4. `diagnostics.tf` applies diagnostics deterministically without discovery data sources.
5. Unit tests and docs are updated to renamed input and new validation rules.

## Implementation Checklist

- [x] Rename diagnostics input in `variables.tf` from `monitoring` to `diagnostic_settings`.
- [x] Add `log_category_groups` to diagnostics schema and corresponding validations.
- [x] Add provider-pinned allow-list validations for log/metric category fields.
- [x] Update `diagnostics.tf` and outputs to consume `diagnostic_settings`.
- [x] Update unit tests and examples to renamed diagnostics input.
- [x] Regenerate docs (`make docs`) and verify TF_DOCS sections.
- [x] Run `terraform validate` and `terraform test -test-directory=tests/unit`.
