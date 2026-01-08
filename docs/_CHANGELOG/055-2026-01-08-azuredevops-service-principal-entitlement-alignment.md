# Filename: 055-2026-01-08-azuredevops-service-principal-entitlement-alignment.md

# 055. Azure DevOps Service Principal Entitlement module compliance alignment

**Date:** 2026-01-08  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_service_principal_entitlement/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-036

---

## Key Changes

- **Single-resource module:** switched to a single entitlement input (no `for_each` on the main resource) and updated outputs to singular values.
- **Examples and fixtures:** refreshed examples, added terraform-docs configs, and added complete/secure/negative fixtures.
- **Tests:** expanded unit tests and implemented Terratest coverage with aligned scripts/config and test outputs scaffolding.
- **Docs:** updated import guidance, module docs, and security notes to match the new API.
