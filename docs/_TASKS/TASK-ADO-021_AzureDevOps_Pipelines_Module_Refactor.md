# TASK-ADO-021: Azure DevOps Pipelines Module Refactor
# FileName: TASK-ADO-021_AzureDevOps_Pipelines_Module_Refactor.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Large
**Dependencies:** TASK-ADO-039, TASK-ADO-041
**Status:** ✅ **Completed (2026-02-14)**

---

## Overview

`modules/azuredevops_pipelines` required another refactor pass to satisfy strict atomic-module boundaries from AGENTS.md and module guide checks.

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

- `azuredevops_build_folder` is independent from `azuredevops_build_definition` and should not live in the same atomic module.
- `azuredevops_build_folder_permissions` is independent from build definition and should be split.
- `azuredevops_build_definition_permissions` supported external `build_definition_id` fallback and was not strict-child only.
- `azuredevops_pipeline_authorization` resources supported external pipeline IDs and were not strict-child only.
- Release references still require `ADOPIv*` normalization (`TASK-ADO-039`).

## Resolution (2026-02-14)

- Module was narrowed to a single non-iterated primary resource (`azuredevops_build_definition`).
- Independent folder scopes (`build_folder`, `build_folder_permissions`) and legacy `resource_authorizations` scope were removed.
- Retained child resources were converted to strict-child-only behavior:
  - `build_definition_permissions` now always binds to module-managed build definition.
  - `pipeline_authorizations` now always bind to module-managed build definition.
- Examples, fixtures, unit tests, integration compile gate, and docs were aligned to the new atomic model.
- Release tag normalization remains tracked separately in `TASK-ADO-039`.

## Scope

- Module: `modules/azuredevops_pipelines/`
- Examples: `modules/azuredevops_pipelines/examples/*`
- Tests: `modules/azuredevops_pipelines/tests/*`
- Docs: module README + root release/version references

## Docs to Update

- `modules/azuredevops_pipelines/README.md`
- `modules/azuredevops_pipelines/docs/README.md`
- `README.md`
- `docs/_TASKS/README.md`

## Work Items

- **Atomic split:** keep only build-definition scope in this module; move independent resources to dedicated modules.
- **Strict-child cleanup:** remove external-ID fallback behavior from resources that remain in this module.
- **Migration path:** provide migration notes for users currently relying on bundled folder/authorization/permission behavior.
- **Tests/examples:** update examples and tests to compose split modules from the consumer layer.
- **Release normalization:** align tags and version links with `ADOPIv*` (`TASK-ADO-039`).

## Acceptance Criteria

- Primary resource remains single and non-iterated.
- No non-child resource remains in `modules/azuredevops_pipelines`.
- No retained resource in module can target external objects via fallback IDs.
- Examples show module composition for split resources.
- Release/tag normalization dependency is explicitly tracked in `TASK-ADO-039`.

## Implementation Checklist

- [x] Split non-child resources out of this module scope to enforce atomic boundary.
- [x] Remove external-ID fallback from resources kept in this module.
- [x] Update examples and tests for composition pattern.
- [x] Add migration notes and refresh module docs.
- [x] Track `ADOPIv*` release normalization in `TASK-ADO-039` (blocked by pipeline/tags).
