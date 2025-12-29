# TASK-010: Workflow and Module Documentation Alignment
# FileName: TASK-010_Workflow_and_Module_Docs_Alignment.md

**Priority:** 🟡 Medium  
**Category:** Documentation / Automation  
**Estimated Effort:** Medium  
**Dependencies:** TASK-009  
**Status:** ✅ **Done** (2025-12-29)

---

## Overview

Synchronize documentation with recent workflow and module changes, ensuring the Azure DevOps modules and repository guides reflect the current CI/CD behavior, doc tooling, and required module docs.

---

## Scope

- Update `docs/WORKFLOWS.md` to reflect scope-first module detection, ADO test secrets, and release shell constraints.
- Refresh `docs/MODULE_GUIDE/*` for module doc requirements and release shell compatibility.
- Ensure all `modules/azuredevops_*` include a **Module Documentation** section linking to `docs/README.md` and `docs/IMPORT.md`.
- Add missing `docs/IMPORT.md` for `modules/azuredevops_wiki`.

---

## Implementation Checklist

- [x] Update workflow documentation to match current module detection and test secret handling.
- [x] Document POSIX shell requirements for `@semantic-release/exec` `prepareCmd`.
- [x] Update module guide for required `docs/README.md` and source reference rules.
- [x] Add **Module Documentation** section to all Azure DevOps modules (except project + project permissions).
- [x] Add missing `modules/azuredevops_wiki/docs/IMPORT.md`.
- [x] Update task and changelog indexes.

---

## Acceptance Criteria

- `docs/WORKFLOWS.md` reflects current workflow behavior and no stale entries remain.
- `docs/MODULE_GUIDE` describes module docs requirements and release shell compatibility.
- All Azure DevOps module READMEs link to `docs/README.md` and `docs/IMPORT.md`.
- Azure DevOps Wiki module includes `docs/IMPORT.md`.
