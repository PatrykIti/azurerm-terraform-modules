# TASK-ADO-039: Azure DevOps Release Tag Normalization and Audit Closure (7 Modules)
# FileName: TASK-ADO-039_AzureDevOps_Release_Tag_Normalization_and_Audit_Closure.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-021, TASK-ADO-022, TASK-ADO-024, TASK-ADO-025, TASK-ADO-026, TASK-ADO-027, docs/MODULE_GUIDE/11-scope-and-provider-coverage-status-check.md, module-release workflow
**Status:** 🟡 To Do

---

## Overview

Close the release-format and audit gap for the remaining Azure DevOps modules where release history still exposes non-`v` tags in public docs/releases, despite `module.json` already using `tag_prefix` with `v`.

Affected modules:
- `modules/azuredevops_pipelines/`
- `modules/azuredevops_serviceendpoint/`
- `modules/azuredevops_servicehooks/`
- `modules/azuredevops_team/`
- `modules/azuredevops_variable_groups/`
- `modules/azuredevops_wiki/`
- `modules/azuredevops_work_items/`

## Mandatory Gate (Atomic Boundary)

Before release normalization is marked done, each affected module must satisfy this gate:
- primary resource is single and non-iterated;
- non-primary resources are strict children only;
- no fallback to external IDs for retained child resources;
- any independent scope is moved to separate atomic module.

## Current Gaps

- `module.json` uses `tag_prefix` with `v` in all 7 modules, but available Git tags are still only legacy non-`v` tags (`ADOPI1.0.0`, `ADOSE1.0.0`, `ADOSH1.0.0`, `ADOT1.0.0`, `ADOVG1.0.0`, `ADOWI1.0.0`, `ADOWK1.0.0`).
- Root module catalog still points to non-`v` releases for these 7 modules (`README.md` Azure DevOps table), which conflicts with current release convention.
- Atomic-boundary closure is still open in dependent tasks `021/022/024/025/026/027`.

## Scope

- Modules: the 7 Azure DevOps modules listed above.
- Release metadata: module release tags, module changelogs, module catalog versions.
- Repo docs: `README.md`, `docs/_TASKS/README.md`, and changelog index/entries as needed.

## Docs to Update

### In-Module
- `modules/azuredevops_pipelines/CHANGELOG.md`
- `modules/azuredevops_serviceendpoint/CHANGELOG.md`
- `modules/azuredevops_servicehooks/CHANGELOG.md`
- `modules/azuredevops_team/CHANGELOG.md`
- `modules/azuredevops_variable_groups/CHANGELOG.md`
- `modules/azuredevops_wiki/CHANGELOG.md`
- `modules/azuredevops_work_items/CHANGELOG.md`

### Repo-Level
- `README.md` (Azure DevOps modules version links)
- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md` + next changelog entry (if policy requires release-format migration note)

## Work Items

- **Atomic-boundary verification:** for each of 7 modules, attach closure evidence that mandatory atomic gate is satisfied.
- **Audit closure:** for each of the 7 modules, attach/update status report per `docs/MODULE_GUIDE/11-scope-and-provider-coverage-status-check.md`.
- **Release normalization:** publish next patch releases with `v` prefixes (`<TAG_PREFIX>vX.Y.Z`) without rewriting historical tags.
- **Documentation alignment:** update root `README.md` so version links point to newest `v`-prefixed tags.
- **Traceability:** add short migration note (legacy non-`v` tags vs current `v` standard) in changelog docs/release note.

## Acceptance Criteria

- Each of the 7 modules has at least one released `v`-prefixed tag reachable from GitHub Releases.
- Root `README.md` Azure DevOps table references `v`-prefixed releases for all 7 modules.
- Audit closure artifacts exist for all 7 modules with statuses and findings per scope/coverage gate.
- Atomic-boundary gate evidence is attached for all 7 modules.
- Existing refactor tasks (`TASK-ADO-021/022/024/025/026/027`) are closed or explicitly listed as blockers.
- No breaking retag/rewrite of existing historical tags is performed.

## Implementation Checklist

- [ ] Verify and document current tag state for all 7 modules (`git tag -l '<PREFIX>*'` evidence).
- [ ] Verify atomic-boundary closure evidence for all 7 modules.
- [ ] Execute/verify module release pipeline to publish `v`-prefixed patch tags for each module.
- [ ] Update root `README.md` version links to new `v` tags.
- [ ] Attach module audit closure reports (status + matrix + action plan).
- [ ] Update `docs/_TASKS/README.md` status/counts.
- [ ] Add changelog note documenting release-tag normalization policy.
