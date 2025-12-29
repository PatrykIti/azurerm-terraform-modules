# Filename: 027-2025-12-25-azuredevops-extension-refactor.md

# 027. Azure DevOps Extension module refactor

**Date:** 2025-12-25  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_extension/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-020

---

## Key Changes

- **Flat inputs:** replaced `extensions` list with `publisher_id`, `extension_id`, and optional `version`.
- **Single resource:** module manages one extension; use module-level `for_each` for multiple installs.
- **Outputs updated:** `extension_ids` map replaced by a single `extension_id` output.
- **Docs & examples:** refreshed examples/fixtures/tests and added import guidance.
