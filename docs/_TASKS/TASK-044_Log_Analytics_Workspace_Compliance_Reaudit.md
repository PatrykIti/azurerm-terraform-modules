# TASK-044: Log Analytics Workspace Compliance Re-audit

**Priority:** High  
**Category:** Compliance / Audit Remediation  
**Estimated Effort:** Large  
**Module:** `modules/azurerm_log_analytics_workspace`  
**Mode:** `AUDIT_ONLY`  
**Primary Resource:** `azurerm_log_analytics_workspace`  
**Provider Version:** `4.57.0`

## Overview
This task tracks remediation work identified during the compliance re-audit of `modules/azurerm_log_analytics_workspace`.

The module currently mixes the primary workspace resource with many additional Log Analytics resource types and diagnostics behavior that does not fully meet current repository compliance expectations (atomic scope, explicit diagnostics validation model, and documentation/test alignment).

## Current Gaps
1. Atomic scope drift: module manages multiple non-primary resources in one module, beyond the single-resource pattern.
2. Diagnostic settings input model is not compliant with current checklist requirements:
- Uses `monitoring` instead of explicit `diagnostic_settings` model.
- Does not validate allowed categories/category-groups against pinned provider support.
- Allows destination empty strings.
- Allows zero-category entries and skips them at runtime instead of failing input validation.
3. Provider coverage verification for `azurerm_log_analytics_workspace` is incomplete in this audit due environment network restrictions (schema/doc fetch blocked).
4. Docs drift and consistency gaps:
- `VERSIONING.md` compatibility matrix references outdated Terraform/provider versions.
- Example READMEs show stale local module source while example `main.tf` files use tagged GitHub source.
- README usage sample includes a workspace name that violates the module name validation pattern.
5. Import documentation is partial for managed sub-resources and should explicitly map import addresses for each managed resource type.
6. Test/docs alignment gaps:
- Unit tests do not cover diagnostics category allow-list and zero-category rejection paths.
- `tests/README.md` mentions `SKIP_TEARDOWN`, but test code does not implement it.
- `run_tests_parallel.sh` redirection pattern is inconsistent for log capture.

## Scope
### In Scope
- Compliance alignment for module structure, scope statement, diagnostics validation model, docs consistency, and test coverage.
- Explicit provider capability matrix validation for `azurerm_log_analytics_workspace` against `azurerm` `4.57.0`.

### Out of Scope
- New feature additions unrelated to compliance findings.
- Changes in unrelated modules.

## Docs to Update
### In-module
- `modules/azurerm_log_analytics_workspace/README.md`
- `modules/azurerm_log_analytics_workspace/docs/README.md`
- `modules/azurerm_log_analytics_workspace/docs/IMPORT.md`
- `modules/azurerm_log_analytics_workspace/SECURITY.md`
- `modules/azurerm_log_analytics_workspace/VERSIONING.md`
- `modules/azurerm_log_analytics_workspace/tests/README.md`

### Outside module
- `docs/MODULE_GUIDE/11-scope-and-provider-coverage-status-check.md` evidence section in PR notes (no file change required unless checklist text is updated by maintainers).
- Optional follow-up task references in `docs/_TASKS/` (handled by parent agent if needed).

## Acceptance Criteria
1. A validated provider schema capability matrix for `azurerm_log_analytics_workspace` (`4.57.0`) is attached in PR and reflected in module docs.
2. Scope decision is explicit and enforced:
- Either module is reduced to primary resource (+ diagnostics exception),
- Or all non-primary resources are explicitly documented as intentional scope with maintainer approval and rationale.
3. Diagnostics input and validation fully comply with checklist requirements:
- Explicit model, provider-pinned category/category-group validation, destination validation including empty-string rejection, and no runtime silent skipping for invalid entries.
4. README/docs/examples are consistent with actual behavior and current pinned versions.
5. Import documentation includes explicit import address patterns for all managed resources or clearly documents intentional limits.
6. Unit/integration test coverage includes diagnostics validation positives/negatives and documentation claims are test-backed.

## Implementation Checklist
- [ ] Confirm maintainer decision on module scope strategy (strict atomic vs intentionally broad).
- [ ] Build and document provider schema matrix for `azurerm_log_analytics_workspace` at `4.57.0`.
- [ ] Refactor diagnostics input/validation model to checklist-compliant behavior.
- [ ] Add/adjust tests for diagnostics validation (allowed categories, category groups if supported, empty destination, zero-category rejection).
- [ ] Fix docs drift in `README.md`, `VERSIONING.md`, and example READMEs/source consistency.
- [ ] Expand `docs/IMPORT.md` with concrete import blocks for each managed resource type (or explicit exclusions).
- [ ] Align `tests/README.md` with actual test behavior and correct script logging behavior.
- [ ] Run validation gates (`fmt`, `validate`, `terraform test`, and test compile/integration where feasible) and attach evidence.
