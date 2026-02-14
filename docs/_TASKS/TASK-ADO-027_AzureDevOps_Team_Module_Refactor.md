# TASK-ADO-027: Azure DevOps Team Module Refactor
# FileName: TASK-ADO-027_AzureDevOps_Team_Module_Refactor.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-039, TASK-ADO-041
**Status:** ✅ **Completed (2026-02-14)**

---

## Overview

`modules/azuredevops_team` requires strict atomic-boundary cleanup for memberships and administrators management.

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

- `azuredevops_team_members` can target external `team_id`, so it is not strict-child only.
- `azuredevops_team_administrators` can target external `team_id`, so it is not strict-child only.
- Current module mixes team creation with reusable membership/administration scopes.
- Release references still require `ADOTv*` normalization (`TASK-ADO-039`).

## Resolution (2026-02-14)

- Team module kept a single non-iterated primary resource (`azuredevops_team`).
- `team_members` and `team_administrators` were converted to strict-child-only behavior (external `team_id` fallback removed).
- Inputs, fixtures, unit tests, integration compile gate, and docs were aligned to strict-child semantics.
- Release tag normalization remains tracked separately in `TASK-ADO-039`.

## Scope

- Module: `modules/azuredevops_team/`
- Examples: `modules/azuredevops_team/examples/*`
- Tests: `modules/azuredevops_team/tests/*`
- Docs: module README + root release/version references

## Docs to Update

- `modules/azuredevops_team/README.md`
- `modules/azuredevops_team/docs/README.md`
- `README.md`
- `docs/_TASKS/README.md`

## Work Items

- **Atomic split:** move team membership/admin scopes to dedicated modules, or make them strict-child-only without external `team_id` support.
- **Scope decision:** pick one model and enforce it in variables, implementation, docs, and tests.
- **Migration path:** document breaking changes for consumers relying on external team targeting.
- **Tests/examples:** update to composition pattern from consumer layer.
- **Release normalization:** align tags and links with `ADOTv*` (`TASK-ADO-039`).

## Acceptance Criteria

- Team module has one non-iterated primary resource and no non-child fallback behavior.
- Membership/admin behavior is either strict-child only or moved to dedicated modules.
- Examples and tests match selected atomic model.
- Release/tag normalization dependency is explicitly tracked in `TASK-ADO-039`.

## Implementation Checklist

- [x] Decide split vs strict-child-only model for membership/admin.
- [x] Implement selected model and remove fallback-based non-child behavior.
- [x] Update examples/tests/docs and migration notes.
- [x] Track `ADOTv*` release normalization in `TASK-ADO-039` (blocked by pipeline/tags).
