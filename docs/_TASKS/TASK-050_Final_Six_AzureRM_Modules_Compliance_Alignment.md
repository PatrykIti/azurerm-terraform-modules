# TASK-050: Final Six AzureRM Modules Compliance Alignment

**Priority:** High  
**Category:** Compliance / Audit Remediation  
**Estimated Effort:** Large  
**Modules:** `modules/azurerm_redis_cache`, `modules/azurerm_role_assignment`, `modules/azurerm_role_definition`, `modules/azurerm_user_assigned_identity`, `modules/azurerm_windows_function_app`, `modules/azurerm_windows_virtual_machine`  
**Status:** 🚧 In Progress (2026-02-09)

---

## Overview

Run final checklist-aligned audit and remediation for the last six target AzureRM modules using:

- `docs/_PROMPTS/MODULE_AUDIT_TASK_PROMPT.md`
- `docs/MODULE_GUIDE/10-checklist.md`
- `docs/MODULE_GUIDE/11-scope-and-provider-coverage-status-check.md`

## Current Gaps

1. Local resource labels are not consistently aligned to provider resource type names (without `azurerm_` prefix).
2. Variable models are still partially flat in selected modules (especially Windows Function App and Windows VM), reducing input ergonomics.
3. Validation vs lifecycle rule placement is inconsistent in several modules.
4. `tests/Makefile` files are inconsistent across the six modules.
5. Module examples/tests need re-validation after refactors.

## Scope

### In scope

- Terraform code alignment in all six modules:
  - variable grouping where beneficial and explicit,
  - resource label naming alignment,
  - cleanup of unnecessary locals/preconditions where variable validations can enforce constraints.
- `tests/Makefile` standardization across all six modules.
- Unit test and example validation checks.
- Documentation/task tracking updates linked to this remediation.

### Out of scope

- Integration test execution (run by module owner with environment credentials).
- Cross-module architecture changes outside the six listed modules.

## Docs to Update

### In-module

- Module `README.md` files (terraform-docs sections if input/output shape changes).
- Module `docs/README.md` and `docs/IMPORT.md` where addressing/inputs changed.

### Outside module

- `docs/_TASKS/README.md`

## Acceptance Criteria

1. All local resource labels in the six modules are provider-aligned (`azurerm_<type>` -> `<type>` label form).
2. Variable models in complex modules are grouped into logical objects without unnecessary nesting.
3. Input-only constraints are enforced primarily in `variables.tf`; `precondition` is retained only where variable validation is insufficient.
4. `tests/Makefile` for all six modules follows one consistent pattern (including compile gate and `test_outputs` logging).
5. For each module:
- `terraform validate` passes,
- `terraform test -test-directory=tests/unit` passes,
- selected examples initialize and validate successfully.

## Implementation Checklist

- [ ] Audit all six modules against checklist 10/11.
- [ ] Align resource labels with provider naming convention.
- [ ] Refactor variable grouping for Windows Function App and Windows VM.
- [ ] Apply targeted variable model/validation cleanup in remaining four modules.
- [ ] Standardize six `tests/Makefile` files.
- [ ] Run module-level validate and unit tests.
- [ ] Run examples init/validate checks.
- [ ] Regenerate module docs where schema changed.
