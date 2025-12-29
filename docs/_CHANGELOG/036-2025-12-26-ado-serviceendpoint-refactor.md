# Filename: 036-2025-12-26-ado-serviceendpoint-refactor.md

# 036. Azure DevOps Service Endpoint module – refactor & alignment

**Date:** 2025-12-26  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_serviceendpoint/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-022

---

## Key Changes

- **Stable keys:** added optional `key` fields with uniqueness validation for all serviceendpoint lists; outputs now reflect stable keys.
- **Permissions resolution:** `serviceendpoint_permissions` can target module-created endpoints via `serviceendpoint_type` + `serviceendpoint_key`.
- **Auth validation:** added cross-field rules for GitHub, AWS, Kubernetes, OpenShift, SSH, and token-vs-basic endpoints.
- **Sensitive inputs:** secret/token/password/private_key inputs are marked sensitive across endpoint types.
- **Examples/tests/docs:** fixed example names, refreshed fixtures/unit tests, and added module import guidance.
