# TASK-ADO-022: Azure DevOps Service Endpoint Module Refactor
# FileName: TASK-ADO-022_AzureDevOps_ServiceEndpoint_Module_Refactor.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Large
**Dependencies:** TASK-ADO-039, TASK-ADO-041
**Status:** 🟠 **Re-opened**

---

## Overview

`modules/azuredevops_serviceendpoint` is still non-compliant with strict atomic-module boundaries and requires decomposition.

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

- Module multiplexes many primary endpoint resources via `count`, which violates single-primary-resource rule.
- Primary resource selection is driven by one-of input across many resource types instead of one atomic module per resource.
- `azuredevops_serviceendpoint_permissions` supports external `serviceendpoint_id` fallback and is not strict-child only.
- Release references still require `ADOSEv*` normalization (`TASK-ADO-039`).

## Scope

- Module: `modules/azuredevops_serviceendpoint/`
- Examples: `modules/azuredevops_serviceendpoint/examples/*`
- Tests: `modules/azuredevops_serviceendpoint/tests/*`
- Docs: module README + root release/version references

## Docs to Update

- `modules/azuredevops_serviceendpoint/README.md`
- `modules/azuredevops_serviceendpoint/docs/README.md`
- `README.md`
- `docs/_TASKS/README.md`

## Work Items

- **Atomic decomposition:** split endpoint types into dedicated atomic modules (one primary provider resource per module).
- **Permissions split:** move `serviceendpoint_permissions` to dedicated module or restrict it to strict-child-only behavior without external-ID fallback.
- **Migration path:** define compatibility/migration guidance for existing consumers of the multiplexed module.
- **Tests/examples:** update to composition pattern and verify parity for key endpoint types.
- **Release normalization:** align tags and links with `ADOSEv*` (`TASK-ADO-039`).

## Acceptance Criteria

- No module contains multiple primary serviceendpoint resource types.
- Each resulting module has one non-iterated primary resource.
- Permissions behavior is strict-child only or moved to dedicated module.
- Examples demonstrate composition from consumer layer.
- Docs reference existing `ADOSEv*` release tags.

## Implementation Checklist

- [ ] Design target module split map for endpoint types.
- [ ] Implement split and migration guidance.
- [ ] Isolate permissions behavior to strict-child or separate module.
- [ ] Update tests/examples/docs for new structure.
- [ ] Publish/confirm `ADOSEv*` release and fix references.
