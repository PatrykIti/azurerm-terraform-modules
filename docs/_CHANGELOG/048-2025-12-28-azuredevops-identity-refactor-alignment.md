# Filename: 048-2025-12-28-azuredevops-identity-refactor-alignment.md

# 048. Azure DevOps Identity module refactor alignment

**Date:** 2025-12-28  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_identity/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-018

---

## Key Changes

- **Single group input:** switched to flat group inputs with optional group creation and module-level `for_each` for multiple groups.
- **Stable keys & validation:** normalized `for_each` keys for memberships, entitlements, and role assignments; added defaulting and key validation.
- **Outputs updated:** exposed singular `group_id`/`group_descriptor` plus stable maps for related resources.
- **Docs & tests:** refreshed examples/fixtures, import guidance, and unit/integration coverage for new validations.
