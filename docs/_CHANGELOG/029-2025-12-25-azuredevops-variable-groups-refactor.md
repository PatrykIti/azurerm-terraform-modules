# Filename: 029-2025-12-25-azuredevops-variable-groups-refactor.md

# 029. Azure DevOps Variable Groups module refactor

**Date:** 2025-12-25  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_variable_groups/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-025

---

## Key Changes

- **Inputs flattened:** replaced `variable_groups` map with flat `name`, `description`, `allow_access`, and `variables` inputs.
- **Key Vault aligned:** replaced `key_vaults` list with a single optional `key_vault` block and validations.
- **Stable permission keys:** updated variable group and library permissions to use stable `key`/`principal`-based `for_each` keys.
- **Outputs updated:** replaced maps with `variable_group_id` and `variable_group_name` outputs.
- **Docs & tests:** refreshed examples, fixtures, unit tests, and added import guidance for the new interface.
