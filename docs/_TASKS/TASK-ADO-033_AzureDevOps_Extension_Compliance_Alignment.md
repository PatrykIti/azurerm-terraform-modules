# TASK-ADO-033: Azure DevOps Extension Compliance Alignment
# FileName: TASK-ADO-033_AzureDevOps_Extension_Compliance_Alignment.md

**Priority:** Medium
**Category:** Azure DevOps Modules
**Estimated Effort:** Small
**Dependencies:** None
**Status:** ✅ **Done** (2026-01-02)

---

## Overview

Align `modules/azuredevops_extension` with MODULE_GUIDE, TESTING_GUIDE, and TERRAFORM_BEST_PRACTICES by addressing layout and documentation gaps found in the audit.

## Current Gaps

- Missing `tests/test_outputs/` directory required by the standard test layout.
- Extra module artifact `modules/azuredevops_extension/.terraform.lock.hcl` committed in the module root.
- `VERSIONING.md` references AzureRM provider versions and outdated Terraform requirements.
- `tests/README.md` omits optional env vars used for secondary extension inputs.
- `docs/README.md` includes guidance about optional child resources and list/object inputs that do not exist in this module.

## Scope

- Module: `modules/azuredevops_extension`
- Tests: `modules/azuredevops_extension/tests/`
- Docs: `modules/azuredevops_extension/VERSIONING.md`, `modules/azuredevops_extension/tests/README.md`, `modules/azuredevops_extension/docs/README.md`

## Docs to Update

### In-Module
- `modules/azuredevops_extension/VERSIONING.md`
- `modules/azuredevops_extension/tests/README.md`
- `modules/azuredevops_extension/docs/README.md`

### Outside Module
- `docs/_TASKS/README.md`

## Acceptance Criteria

- `tests/test_outputs/` exists and aligns with the repo testing layout.
- `modules/azuredevops_extension/.terraform.lock.hcl` is removed from the module root.
- `VERSIONING.md` reflects Terraform `>= 1.12.2` and Azure DevOps provider `1.12.2` with no AzureRM references.
- `tests/README.md` documents the optional secondary extension env vars.
- `docs/README.md` reflects only behaviors supported by the module.

## Implementation Checklist

- [ ] Add `modules/azuredevops_extension/tests/test_outputs/` (and adjust .gitignore if required).
- [ ] Remove `modules/azuredevops_extension/.terraform.lock.hcl` from the module root.
- [ ] Update `modules/azuredevops_extension/VERSIONING.md` compatibility matrix and provider references.
- [ ] Update `modules/azuredevops_extension/tests/README.md` with secondary extension env vars.
- [ ] Adjust `modules/azuredevops_extension/docs/README.md` to remove non-applicable guidance.
- [ ] Update `docs/_TASKS/README.md` stats and task list entry.
