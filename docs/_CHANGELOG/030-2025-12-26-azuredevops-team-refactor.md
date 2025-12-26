# Filename: 030-2025-12-26-azuredevops-team-refactor.md

# 030. Azure DevOps Team module refactor

**Date:** 2025-12-26  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_team/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-027

---

## Key Changes

- **Stable keys:** team members and administrators now use derived keys for `for_each` and outputs.
- **Validation tightened:** selector rules, team key references, uniqueness checks, and non-empty names/descriptors.
- **Defaults:** membership/admin `mode` now defaults to `add`.
- **Docs & examples:** added import guidance and fixed-name examples with key inputs.
- **Tests:** updated unit/integration coverage for new validations and output keys.
