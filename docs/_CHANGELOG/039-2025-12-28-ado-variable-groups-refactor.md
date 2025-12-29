# Filename: 039-2025-12-28-ado-variable-groups-refactor.md

# 039. Azure DevOps Variable Groups module – refactor alignment (re-opened)

**Date:** 2025-12-28  
**Type:** Maintenance / Documentation  
**Scope:** `modules/azuredevops_variable_groups/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-025

---

## Key Changes

- **Permission defaults clarified:** `replace` now defaults to true in permissions inputs to match module behavior.
- **Integration validation:** integration test checks that variable group and library permissions resources are created.
- **Docs refreshed:** import guidance includes stable key notes and verification steps; README and module metadata updated.
- **Examples aligned:** secure example now uses an explicit permission key for stable addressing.
