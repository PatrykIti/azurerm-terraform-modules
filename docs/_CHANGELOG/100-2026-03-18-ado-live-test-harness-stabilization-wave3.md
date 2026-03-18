# Filename: 100-2026-03-18-ado-live-test-harness-stabilization-wave3.md

# 100. Azure DevOps live test harness stabilization wave 3

**Date:** 2026-03-18  
**Type:** Maintenance / Documentation  
**Scope:** `modules/azuredevops_*/tests/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-044

---

## Key Changes

- Stabilized live Terratest cleanup so deploy and cleanup reuse the same saved `TerraformOptions` when available.
- Added retry handling for known Azure DevOps/provider transient failures:
  - `connection reset by peer`
  - `invalid character '<' looking for beginning of value`
- Applied the stabilization wave to the remaining Azure DevOps test suites:
  - `azuredevops_agent_pools`
  - `azuredevops_elastic_pool`
  - `azuredevops_environments`
  - `azuredevops_extension`
  - `azuredevops_group`
  - `azuredevops_group_entitlement`
  - `azuredevops_service_principal_entitlement`
  - `azuredevops_servicehooks`
  - `azuredevops_team`
  - `azuredevops_variable_groups`

## Board Updates

- Added `TASK-ADO-044` and marked it **Done**.
- Updated task board statistics in `docs/_TASKS/README.md`.
