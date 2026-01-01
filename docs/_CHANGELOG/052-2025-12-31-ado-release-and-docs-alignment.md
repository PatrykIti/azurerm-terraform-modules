# Filename: 052-2025-12-31-ado-release-and-docs-alignment.md

# 052. Azure DevOps modules release and docs alignment

**Date:** 2025-12-31  
**Type:** Maintenance / Documentation  
**Scope:** `modules/azuredevops_*/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-030

---

## Key Changes

- Standardized Azure DevOps module tag prefixes to include `v` and aligned VERSIONING formats.
- Updated `.releaserc.js` across ADO modules to use `git::https` sources and handle `../../`, `../../../`, and `../..` patterns.
- Replaced placeholder `docs/README.md` content with concise technical guidance for ADO modules.
- Updated import docs and examples to use `git::https` sources with `*vX.Y.Z` tag refs.
- Switched VERSIONING source examples to `git::https://github.com/...` format.
