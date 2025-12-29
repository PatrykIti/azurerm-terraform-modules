# Filename: 040-2025-12-28-ado-servicehooks-refactor-reopened.md

# 040. Azure DevOps Service Hooks module refactor (reopened)

**Date:** 2025-12-28  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_servicehooks/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-024

---

## Key Changes

- **Single hook inputs:** replaced webhook/storage queue lists with single-object inputs; use module-level for_each for multiples.
- **Stable permissions keys:** permissions are keyed by optional `key` or `principal`, with values normalized to Allow/Deny/NotSet.
- **Validation tightening:** event selection, non-empty fields, enum checks, and non-negative ttl/visi_timeout.
- **Sensitive inputs:** webhook basic auth and storage account keys are marked sensitive.
- **Docs/tests refreshed:** README, import guidance, examples, fixtures, and unit/integration tests updated for the new interface.
