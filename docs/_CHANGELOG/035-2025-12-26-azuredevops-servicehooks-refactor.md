# Filename: 035-2025-12-26-azuredevops-servicehooks-refactor.md

# 035. Azure DevOps Service Hooks module refactor

**Date:** 2025-12-26  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_servicehooks/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-024

---

## Key Changes

- **Stable keys:** webhooks, storage queue hooks, and permissions now use optional `key` values for stable `for_each` addressing.
- **Stricter validation:** added event-block, enum, numeric, and permission validation, plus uniqueness rules per list input.
- **Permissions normalized:** permission values are normalized to `Allow`/`Deny`/`NotSet` before apply.
- **Sensitive handling:** `basic_auth_password` and `account_key` are treated as sensitive values.
- **Docs/tests refreshed:** examples, fixtures, unit/integration tests, outputs, and import guidance updated.
