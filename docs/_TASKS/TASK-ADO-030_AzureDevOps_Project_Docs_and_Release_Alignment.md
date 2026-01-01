# TASK-ADO-030: Azure DevOps Project Docs and Release Alignment
# FileName: TASK-ADO-030_AzureDevOps_Project_Docs_and_Release_Alignment.md

**Priority:** 🟡 Medium
**Category:** Documentation / Release Automation
**Estimated Effort:** Small
**Dependencies:** —
**Status:** ✅ **Done** (2025-12-31)

---

## Overview

Align module documentation and release-time source URL updates across
`modules/azuredevops_*`. Ensure all Azure DevOps modules use `git::https://`
sources in examples/import docs and use `*vX.Y.Z` tag formats.

---

## Scope

1) **Docs**
   - Replace placeholders in `modules/azuredevops_*/docs/README.md`.
   - Keep content concise and technical (overview, scope, inputs/outputs, import, troubleshooting).

2) **Release Config**
   - Update `modules/azuredevops_*/.releaserc.js` to replace sources for:
     - `git::https://...`
     - `../../`
     - `../../../`
     - `../..`

3) **Tag Prefix and References**
   - Update `modules/azuredevops_*/module.json` to include `v` in `tag_prefix`.
   - Align examples, import docs, and VERSIONING references to `{TAG_PREFIX}v{version}` and `git::https://` sources.

---

## Acceptance Criteria

- `modules/azuredevops_*/docs/README.md` contains concrete, runnable guidance.
- `.releaserc.js` updates example sources for all listed patterns across ADO modules.
- Module tag prefixes and references use `*v{version}` consistently.
- Examples and import docs reference `git::https://...` sources.

---

## Updates (Done)

- Replaced placeholder `docs/README.md` across `modules/azuredevops_*` with concise technical guidance.
- Updated `.releaserc.js` across ADO modules to handle `git::https` and relative source patterns.
- Normalized `tag_prefix` values to include `v` and aligned `VERSIONING.md` formats.
- Updated examples and import docs to use `git::https` sources and `*v` tag refs.

---

## Implementation Checklist

- [x] Update `modules/azuredevops_*/docs/README.md`.
- [x] Update `modules/azuredevops_*/module.json` tag prefix.
- [x] Update `modules/azuredevops_*/.releaserc.js` source patterns.
- [x] Align references in examples, import docs, and VERSIONING.
