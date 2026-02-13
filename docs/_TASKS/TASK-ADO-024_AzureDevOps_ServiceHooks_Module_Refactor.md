# TASK-ADO-024: Azure DevOps Service Hooks Module Refactor
# FileName: TASK-ADO-024_AzureDevOps_ServiceHooks_Module_Refactor.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-039, TASK-ADO-041
**Status:** 🟠 **Re-opened**

---

## Overview

`modules/azuredevops_servicehooks` needs an atomic-boundary refactor. Current scope mixes independent resource types in one module.

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
- Docs reference existing `ADOSHv*` release tags.

## Implementation Checklist

- [ ] Split webhook, storage-queue, and permissions scopes into separate modules.
- [ ] Add migration notes and deprecation guidance.
- [ ] Update tests/examples for composition model.
- [ ] Regenerate docs for all affected modules.
- [ ] Publish/confirm `ADOSHv*` release and fix references.
