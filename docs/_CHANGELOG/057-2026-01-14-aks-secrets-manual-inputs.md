# Filename: 057-2026-01-14-aks-secrets-manual-inputs.md

# 057. AKS secrets manual strategy input refactor

**Date:** 2026-01-14  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azurerm_kubernetes_secrets/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-015

---

## Key Changes

- Removed Key Vault data sources from the module; manual strategy now accepts caller-provided values.
- Dropped the `azurerm` provider requirement from the module.
- Updated manual example, fixtures, and unit tests to pass secret values directly.
- Refreshed module docs, security notes, and task index to reflect the breaking change.
