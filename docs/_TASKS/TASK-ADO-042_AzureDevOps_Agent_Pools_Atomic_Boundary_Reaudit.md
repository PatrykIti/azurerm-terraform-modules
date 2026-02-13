# TASK-ADO-042: Azure DevOps Agent Pools Atomic Boundary Re-audit
# FileName: TASK-ADO-042_AzureDevOps_Agent_Pools_Atomic_Boundary_Reaudit.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-015, docs/MODULE_GUIDE/10-checklist.md, docs/MODULE_GUIDE/11-scope-and-provider-coverage-status-check.md
**Status:** 🟡 To Do

---

## Overview

Re-audit `modules/azuredevops_agent_pools` against strict atomic boundaries.

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

- `azuredevops_elastic_pool` is not a strict child of `azuredevops_agent_pool` and can be managed independently.
- Module currently mixes independent pool scopes in one module path.
- Task `TASK-ADO-015` is marked done but this boundary issue remains unresolved.

## Scope

- Module: `modules/azuredevops_agent_pools/`
- Examples: `modules/azuredevops_agent_pools/examples/*`
- Tests: `modules/azuredevops_agent_pools/tests/*`
- Docs: module README + task board

## Work Items

- **Atomic split:** separate `elastic_pool` scope into dedicated module.
- **Team-facing migration:** provide migration notes and consumer composition examples.
- **Regression tests:** add tests proving split scopes work in composition.

## Acceptance Criteria

- `modules/azuredevops_agent_pools` contains only strict-child resources for its primary scope.
- `elastic_pool` scope is moved to dedicated module or removed from this module.
- Examples/tests reflect consumer-level composition.
- Task board status and closure report are updated.

## Implementation Checklist

- [ ] Define split target module for elastic pool scope.
- [ ] Refactor module/examples/tests/docs.
- [ ] Add migration guidance.
- [ ] Update task board and closure evidence.
