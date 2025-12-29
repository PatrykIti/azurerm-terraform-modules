# Filename: 031-2025-12-26-azuredevops-environments-refactor.md

# 031. Azure DevOps Environments module refactor

**Date:** 2025-12-26  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_environments/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-017

---

## Key Changes

- **Single environment input:** replaced `environments` map with flat inputs (`project_id`, `name`, `description`).
- **Stable child resources:** Kubernetes resources and checks use stable keys with validation and default targeting.
- **Check validation:** added allowed values for `target_resource_type` and approvals minimum approver validation.
- **Outputs updated:** added `environment_id` output and stable keyed maps for resources/checks.
- **Docs & tests:** refreshed examples, fixtures, unit tests, and import guidance for the new interface.
