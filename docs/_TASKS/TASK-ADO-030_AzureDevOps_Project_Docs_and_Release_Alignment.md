# TASK-ADO-030: Azure DevOps Project Docs and Release Alignment
# FileName: TASK-ADO-030_AzureDevOps_Project_Docs_and_Release_Alignment.md

**Priority:** 🟡 Medium
**Category:** Documentation / Release Automation
**Estimated Effort:** Small
**Dependencies:** —
**Status:** Proposed

---

## Overview

Align module documentation and release-time source URL updates for
`modules/azuredevops_project`. Ensure the module uses `git::https://` sources
in examples/import docs and that release tags follow the `ADOPvX.Y.Z` format.

---

## Scope

1) **Docs**
   - Replace placeholders in `modules/azuredevops_project/docs/README.md`.
   - Keep content concise and technical (overview, scope, inputs/outputs, import, troubleshooting).

2) **Release Config**
   - Update `modules/azuredevops_project/.releaserc.js` to replace sources for:
     - `git::https://...`
     - `../../`
     - `../../../`
     - `../..`

3) **Tag Prefix and References**
   - Update `modules/azuredevops_project/module.json` to `tag_prefix = "ADOPv"`.
   - Align example and import references to `ADOPv{version}`.

---

## Acceptance Criteria

- `modules/azuredevops_project/docs/README.md` contains concrete, runnable guidance.
- `.releaserc.js` updates example sources for all listed patterns.
- Module tag prefix and references use `ADOPv{version}` consistently.
- Examples and import doc reference `git::https://...` sources.

---

## Implementation Checklist

- [ ] Update `modules/azuredevops_project/docs/README.md`.
- [ ] Update `modules/azuredevops_project/module.json` tag prefix.
- [ ] Update `modules/azuredevops_project/.releaserc.js` source patterns.
- [ ] Align references in examples and `docs/IMPORT.md`.
