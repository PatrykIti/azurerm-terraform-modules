# TASK-ADO-026: Azure DevOps Work Items Module Refactor
# FileName: TASK-ADO-026_AzureDevOps_Work_Items_Module_Refactor.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Large
**Dependencies:** TASK-ADO-039, TASK-ADO-041
**Status:** 🟠 **Re-opened**

---

## Overview

`modules/azuredevops_work_items` is currently a composite module spanning multiple independent provider resource families and must be decomposed.

## Mandatory Rule (Atomic Boundary)

- Primary resource in a module must be single and non-iterated (`no for_each`, `no count` on primary block).
- Additional resources may remain only when they are strict children of that primary resource.
- Strict child means direct dependency on module-managed primary resource and no external-ID fallback.
- If a resource can operate without module primary resource (for example via external `*_id` input), it must be moved to a separate atomic module.
- Multiplicity belongs in consumer configuration via module-level `for_each`.

## Current Gaps

- Module contains multiple independent primary scopes (`workitem`, `process`, `query_folder`, `query`, and multiple permissions resources).
- Several resources are iterable primaries in the same module (`for_each` on non-child families).
- Query and permission resources can be managed independently from work item creation, violating atomic boundary.
- Release references still require `ADOWKv*` normalization (`TASK-ADO-039`).

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
- Docs reference existing `ADOWKv*` release tags.

## Implementation Checklist

- [ ] Define target split map for work-item resource families.
- [ ] Implement decomposition with migration guidance.
- [ ] Remove non-child fallback coupling.
- [ ] Update tests/examples/docs to composition model.
- [ ] Publish/confirm `ADOWKv*` release and fix references.
