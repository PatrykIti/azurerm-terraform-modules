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

## Current Gaps

- `module.json` uses `tag_prefix` with `v` in all 7 modules, but available Git tags are still only legacy non-`v` tags (`ADOPI1.0.0`, `ADOSE1.0.0`, `ADOSH1.0.0`, `ADOT1.0.0`, `ADOVG1.0.0`, `ADOWI1.0.0`, `ADOWK1.0.0`).
- Root module catalog still points to non-`v` releases for these 7 modules (`README.md` Azure DevOps table), which conflicts with current release convention.
- Release/audit closure is fragmented across multiple module refactor tasks; there is no single closure step that confirms status gate + release tag normalization end-to-end.

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

- **Audit closure:** For each of the 7 modules, attach/update status report per `docs/MODULE_GUIDE/11-scope-and-provider-coverage-status-check.md` (Scope Status, Provider Coverage Status, Overall Status, findings, matrix, action plan).
- **Release normalization:** Publish next patch releases with `v` prefixes (`<TAG_PREFIX>vX.Y.Z` format already encoded in `module.json`), without rewriting historical immutable tags.
- **Documentation alignment:** Update root `README.md` so version links point to newest `v`-prefixed tags for all 7 modules.
- **Traceability:** Add short migration note (legacy non-`v` tags vs current `v` standard) in changelog docs/release note.
- **Verification gate:** Confirm no Azure DevOps module in root `README.md` references latest non-`v` tag as canonical version.

## Acceptance Criteria

- Each of the 7 modules has at least one released `v`-prefixed tag reachable from GitHub Releases.
- Root `README.md` Azure DevOps table references `v`-prefixed releases for all 7 modules.
- Audit closure artifacts exist for all 7 modules with statuses and findings per scope/coverage gate.
- Existing refactor tasks (`TASK-ADO-021/022/024/025/026/027`) are either closed or explicitly linked as residual blockers from this task.
- No breaking retag/rewrite of existing historical tags is performed.

## Implementation Checklist

- [ ] Verify and document current tag state for all 7 modules (`git tag -l '<PREFIX>*'` evidence).
- [ ] Execute/verify module release pipeline to publish `v`-prefixed patch tags for each module.
- [ ] Update root `README.md` version links to new `v` tags.
- [ ] Add/attach audit closure report for each module (status + matrix + action plan).
- [ ] Update `docs/_TASKS/README.md` status/counts.
- [ ] Add changelog note documenting release-tag normalization policy.
