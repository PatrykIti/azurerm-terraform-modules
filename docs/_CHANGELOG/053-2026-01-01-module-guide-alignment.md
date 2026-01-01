# Filename: 053-2026-01-01-module-guide-alignment.md

# 053. Module guide alignment (AKS + Azure DevOps patterns)

**Date:** 2026-01-01  
**Type:** Maintenance / Documentation  
**Scope:** `docs/MODULE_GUIDE/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-012

---

## Key Changes

- Marked `docs/README.md` as optional and aligned its recommended layout to Azure DevOps module docs.
- Updated `.terraform-docs.yml` guidance to match the minimal AKS/ADO config and keep Usage/Examples outside TF_DOCS markers.
- Added guidance for provider-required blocks, `count` vs `for_each`, and avoiding `try/coalesce` via `nullable = false`.
- Clarified Azure DevOps example expectations (fixed names, existing project ID) and AzureRM naming rules.
- Clarified that PR title scope allowlist updates in `pr-validation.yml` are required when using new `commit_scope` values.
