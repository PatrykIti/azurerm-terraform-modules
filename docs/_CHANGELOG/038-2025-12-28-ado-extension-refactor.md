# Filename: 038-2025-12-28-ado-extension-refactor.md

# 038. Azure DevOps Extension module – refactor follow-up

**Date:** 2025-12-28  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_extension/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-020

---

## Key Changes

- **Input naming:** retained `extension_version` for the optional pin because `version` is reserved in Terraform module blocks.
- **Examples & tests:** refreshed fixtures, examples, and unit/integration tests to align with module-level `for_each`.
- **Docs:** updated module README, import guide, and security example to match the input name and document the reserved keyword note.
