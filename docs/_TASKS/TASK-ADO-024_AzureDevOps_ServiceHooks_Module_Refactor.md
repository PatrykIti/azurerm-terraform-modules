# TASK-ADO-024: Azure DevOps Service Hooks Module Refactor
# FileName: TASK-ADO-024_AzureDevOps_ServiceHooks_Module_Refactor.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-039, TASK-ADO-041
**Status:** ✅ **Completed (2026-02-14)**

---

## Overview

`modules/azuredevops_servicehooks` needs an atomic-boundary refactor. Current scope mixes independent resource types in one module.

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

- `azuredevops_servicehook_webhook_tfs` and `azuredevops_servicehook_storage_queue_pipelines` are two independent primaries in one module.
- Both hook resources are conditionally created with `count` and are not strict parent-child.
- `azuredevops_servicehook_permissions` is independent and not anchored to a module-managed hook resource.
- Release references still require `ADOSHv*` normalization (`TASK-ADO-039`).

## Resolution (2026-02-14)

- Module was narrowed to a single non-iterated primary resource (`azuredevops_servicehook_webhook_tfs`).
- Independent storage-queue and permissions scopes were removed from this module to enforce atomic boundary.
- Examples, fixtures, unit tests, integration compile gate, and docs were aligned to webhook-only scope.
- Release tag normalization remains tracked separately in `TASK-ADO-039`.

## Scope

- Module: `modules/azuredevops_servicehooks/`
- Examples: `modules/azuredevops_servicehooks/examples/*`
- Tests: `modules/azuredevops_servicehooks/tests/*`
- Docs: module README + root release/version references

## Docs to Update

- `modules/azuredevops_servicehooks/README.md`
- `modules/azuredevops_servicehooks/module.json`
- `README.md`
- `docs/_TASKS/README.md`

## Work Items

- **Atomic split:** separate webhook, storage-queue hook, and permissions into dedicated modules.
- **Scope cleanup:** remove mixed-mode behavior from a single module instance.
- **Migration path:** document breaking-change migration for existing consumers.
- **Tests/examples:** update to composition pattern with module-level orchestration.
- **Release normalization:** align tags and links with `ADOSHv*` (`TASK-ADO-039`).

## Acceptance Criteria

- No module contains multiple primary hook resource types.
- Each resulting module has one non-iterated primary resource.
- Permissions are managed in dedicated module or strict-child-only context.
- Examples and tests show composition rather than in-module multiplexing.
- Release/tag normalization dependency is explicitly tracked in `TASK-ADO-039`.

## Implementation Checklist

- [x] Split scope by reducing this module to webhook-only and removing independent storage-queue/permissions behavior.
- [x] Add migration notes and deprecation guidance.
- [x] Update tests/examples for composition model.
- [x] Regenerate docs for all affected modules.
- [x] Track `ADOSHv*` release normalization in `TASK-ADO-039` (blocked by pipeline/tags).
