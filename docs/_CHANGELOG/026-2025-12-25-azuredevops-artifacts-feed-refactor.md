# Filename: 026-2025-12-25-azuredevops-artifacts-feed-refactor.md

# 026. Azure DevOps Artifacts Feed module refactor

**Date:** 2025-12-25  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_artifacts_feed/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-019

---

## Key Changes

- **Feed inputs expanded:** add feed description and validate feed name/project_id/description when provided.
- **Stable child keys:** permissions and retention policies use stable keys with uniqueness validation.
- **Derived project IDs:** permissions/retention derive project_id from feed when feed_key is used.
- **Role normalization:** permission roles are normalized to lowercase before provider calls.
- **Docs & tests:** refreshed examples, fixtures, unit tests, and import guidance; README docs regenerated.
