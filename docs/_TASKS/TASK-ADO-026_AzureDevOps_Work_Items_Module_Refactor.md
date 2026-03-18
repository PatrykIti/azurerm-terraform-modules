# TASK-ADO-026: Azure DevOps Work Items Module Refactor
# FileName: TASK-ADO-026_AzureDevOps_Work_Items_Module_Refactor.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Large
**Dependencies:** TASK-ADO-039, TASK-ADO-041
**Status:** ✅ **Completed (2026-02-14)**

---

## Overview

`modules/azuredevops_work_items` was a composite module spanning multiple independent provider resource families and required decomposition.

## Planning Assumption

- No active production consumers yet (owner confirmation, 2026-02-13).
- Breaking changes are explicitly allowed for atomic-boundary alignment.
- Backward-compatibility shims are optional; prioritize clean target architecture.

## Mandatory Rule (Atomic Boundary)

- Primary resource in a module must be single and non-iterated (`no for_each`, `no count` on primary block).
- Additional resources may remain only when they are strict children of that primary resource.
- Strict child means direct dependency on module-managed primary resource and no external-ID fallback.
- If a resource can operate without module primary resource (for example via external `*_id` input), it must be moved to a separate atomic module.
- Multiplicity belongs in consumer configuration via module-level `for_each`.

## Current Gaps

- Module contained multiple independent primary scopes (`workitem`, `process`, `query_folder`, `query`, and multiple permissions resources).
- Several resources were iterable primaries in the same module (`for_each` on non-child families).
- Query and permission resources could be managed independently from work item creation, violating atomic boundary.
- Release references still require `ADOWKv*` normalization (`TASK-ADO-039`).

## Resolution (2026-02-14)

- Module was narrowed to a single non-iterated primary resource (`azuredevops_workitem`).
- Independent scopes were removed from this module: process, query folders, queries, and permissions families.
- Inputs, outputs, examples, fixtures, unit tests, integration compile gate, and docs were aligned to work-item-only atomic scope.
- Composition pattern for parent/child work items is demonstrated in examples/tests using multiple module instances.
- Release tag normalization remains tracked separately in `TASK-ADO-039`.

## Scope

- Module: `modules/azuredevops_work_items/`
- Examples: `modules/azuredevops_work_items/examples/*`
- Tests: `modules/azuredevops_work_items/tests/*`
- Docs: module README + scope docs + root release/version references

## Docs to Update

- `modules/azuredevops_work_items/README.md`
- `modules/azuredevops_work_items/docs/README.md`
- `README.md`
- `docs/_TASKS/README.md`

## Work Items

- **Atomic decomposition:** split module into resource-family modules (work item, process, query folders/queries, permissions families).
- **Strict-child policy:** prevent cross-family fallback behavior inside a single module.
- **Migration path:** document breaking changes and composition examples for consumers.
- **Tests/examples:** rebuild tests and examples around composition of atomic modules.
- **Release normalization:** align tags and links with `ADOWKv*` (`TASK-ADO-039`).

## Acceptance Criteria

- No module spans multiple independent work-item resource families.
- Each resulting module has one non-iterated primary resource.
- Cross-family fallback linking is removed from module internals.
- Examples and tests use composition in consumer layer.
- Release/tag normalization dependency is explicitly tracked in `TASK-ADO-039`.

## Implementation Checklist

- [x] Define target split map for work-item resource families.
- [x] Implement decomposition with migration guidance.
- [x] Remove non-child fallback coupling.
- [x] Update tests/examples/docs to composition model.
- [x] Track `ADOWKv*` release normalization in `TASK-ADO-039` (blocked by pipeline/tags).
