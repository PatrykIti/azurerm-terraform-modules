# Filename: 047-2025-12-28-ado-artifacts-feed-refactor.md

# 047. Azure DevOps Artifacts Feed module refactor

**Date:** 2025-12-28  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_artifacts_feed/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-019

---

## Key Changes

- **Single-feed inputs:** replaced the feeds map with flat `name`, `project_id`, `description`, and `features` inputs.
- **Stable child keys:** permissions/retention use stable keys with uniqueness validation and role normalization.
- **Derived defaults:** permissions/retention derive `feed_id`/`project_id` from the module feed when omitted; validations enforce `feed_id` when no feed exists.
- **Outputs & docs:** outputs switched to single feed outputs plus permission/retention IDs; README/IMPORT/security/examples updated.
- **Tests:** unit tests, fixtures, and Terratest scenarios updated for new defaults and validation rules.
