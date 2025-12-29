# TASK-ADO-028: Azure DevOps Contributing Docs Alignment
# FileName: TASK-ADO-028_AzureDevOps_Contributing_Docs_Alignment.md

**Priority:** 🟡 Medium
**Category:** Azure DevOps Modules
**Estimated Effort:** Small
**Dependencies:** None
**Status:** ✅ **Done** (2025-12-29)

---

## Overview

Standardize `CONTRIBUTING.md` across Azure DevOps modules to remove hardcoded test paths.
Use a module-local test command (`cd tests && make test`) and update the template to prevent
regressions. Verify there are no placeholder tokens left in module docs.

## Scope

- `modules/azuredevops_*/CONTRIBUTING.md`
- `scripts/templates/CONTRIBUTING.md`

## Current Gaps (Summary)

- Test instructions use hardcoded `cd modules/azuredevops_*/tests` paths.
- Template still embeds hardcoded test path and placeholder tokens.
- No consistent note that commands are run from the module root.

## Target State

- Test instructions: `cd tests && make test` (run from module root).
- Template uses relative paths only; no placeholder tokens remain in generated files.
- Azure DevOps module `CONTRIBUTING.md` files contain no hardcoded module paths.

## Implementation Checklist

- [ ] Update `scripts/templates/CONTRIBUTING.md` test command to `cd tests && make test`.
- [ ] Update all `modules/azuredevops_*/CONTRIBUTING.md` test command to `cd tests && make test`.
- [ ] Confirm no placeholder tokens remain in `modules/azuredevops_*/CONTRIBUTING.md` (`rg "PLACEHOLDER"`).
- [ ] Verify no hardcoded test paths remain (`rg "cd modules/azuredevops_.*?/tests" modules/azuredevops_*`).
- [ ] Update `docs/_TASKS/README.md`.

## Acceptance Criteria

- All Azure DevOps module `CONTRIBUTING.md` files use `cd tests && make test`.
- Template uses relative test paths only.
- `rg "cd modules/azuredevops_.*?/tests" modules/azuredevops_*` returns no matches.
- No `*_PLACEHOLDER` tokens remain in `modules/azuredevops_*/CONTRIBUTING.md`.
