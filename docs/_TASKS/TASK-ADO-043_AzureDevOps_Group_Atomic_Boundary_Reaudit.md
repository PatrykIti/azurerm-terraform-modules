# TASK-ADO-043: Azure DevOps Group Atomic Boundary Re-audit
# FileName: TASK-ADO-043_AzureDevOps_Group_Atomic_Boundary_Reaudit.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-018, docs/MODULE_GUIDE/10-checklist.md, docs/MODULE_GUIDE/11-scope-and-provider-coverage-status-check.md
**Status:** 🟡 To Do

---

## Overview

Re-audit `modules/azuredevops_group` for strict atomic boundaries and fallback-free child behavior.

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

- `azuredevops_group_entitlement` is independent of module-managed `azuredevops_group`.
- `azuredevops_group_membership` accepts external `group_descriptor`, so it is not strict-child only.
- Module currently mixes group creation with reusable external-target scopes.

## Scope

- Module: `modules/azuredevops_group/`
- Examples: `modules/azuredevops_group/examples/*`
- Tests: `modules/azuredevops_group/tests/*`
- Docs: module README + task board

## Work Items

- **Atomic split:** separate `group_membership` and `group_entitlement` scopes into dedicated modules, or enforce strict-child-only behavior.
- **Fallback cleanup:** remove external-target fallback behavior from resources retained in the group module.
- **Migration and docs:** provide migration guide and composition examples.

## Acceptance Criteria

- `modules/azuredevops_group` has one non-iterated primary resource and no non-child fallback behavior.
- Independent entitlement/membership scope is split or strictly anchored to module-managed group.
- Examples/tests/docs reflect final atomic model.
- Task board and closure report are updated.

## Implementation Checklist

- [ ] Choose split vs strict-child-only model and document decision.
- [ ] Refactor resources, variables, outputs, examples, and tests.
- [ ] Remove fallback behavior for retained resources.
- [ ] Publish migration notes and update task board.
