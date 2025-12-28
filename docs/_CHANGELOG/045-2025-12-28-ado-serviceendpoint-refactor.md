# Filename: 045-2025-12-28-ado-serviceendpoint-refactor.md

# 045. Azure DevOps Service Endpoint module – refactor follow-up

**Date:** 2025-12-28  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_serviceendpoint/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-022

---

## Key Changes

- **Single endpoint per module:** replaced list-based inputs with one optional object per endpoint type and added a strict one-endpoint validation.
- **Permissions workflow:** permissions default to the module-created endpoint ID, with stable keys based on `coalesce(key, principal)`.
- **Auth-mode validation:** enforced cross-field rules for GitHub, AWS, Kubernetes, OpenShift, SSH, and token-vs-basic endpoint types.
- **Docs/examples/tests:** updated usage, import guide, examples, fixtures, and unit/terratest coverage for the new interface.
