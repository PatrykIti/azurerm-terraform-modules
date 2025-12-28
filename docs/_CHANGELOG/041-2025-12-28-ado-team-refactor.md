# Filename: 041-2025-12-28-ado-team-refactor.md

# 041. Azure DevOps Team module refactor (re-opened alignment)

**Date:** 2025-12-28  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_team/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-027

---

## Key Changes

- **Single team resource:** replaced `teams` map with flat `name`/`description` inputs and module-level for_each for multiple instances.
- **Stable keys:** members/admins use derived `coalesce(key, team_id)` keys with explicit validations and defaults.
- **Defaults and validation:** mode defaults to `add`, team_id defaults to the module team, and list validation now enforces non-empty, unique inputs.
- **Docs and examples:** updated import guidance and fixed-name examples showing module-level for_each usage.
- **Tests:** refreshed unit, fixtures, and Terratest assertions for new outputs and validation behavior.
