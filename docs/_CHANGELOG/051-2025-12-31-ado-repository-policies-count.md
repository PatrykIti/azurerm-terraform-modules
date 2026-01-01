# Filename: 051-2025-12-31-ado-repository-policies-count.md

# 051. Azure DevOps Repository policies - count-based repo policies

**Date:** 2025-12-31  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_repository/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-029

---

## Key Changes

- Switched repository-level policy resources to `count` (single instance) instead of `for_each`; addresses now use `[0]` when enabled.
- Updated `policy_ids` output handling and import documentation for the new count-based repo policies.
- Set `policies` default to `{}` with `nullable = false` to avoid null guards.
- Standardized branch policy locals to map by branch name with `policies` default `{}` for direct access in locals/resources.
- Removed `try`/`coalesce` from list policy locals and validations; added validation that `branches.policies` cannot be `null`.
- Expanded `docs/IMPORT.md` with keying rules, provider notes, and Azure CLI helper commands; aligned `docs/README.md` structure with module usage notes.
- Aligned `modules/azuredevops_repository/.releaserc.js` with updated source URL and README/examples replacement rules.
- Branch creation now requires exactly one of `ref_branch`, `ref_tag`, or `ref_commit_id`; removed implicit fallback to `default_branch`.
- `initialization` now defaults to `init_type = "Uninitialized"` and the block is always sent (provider requires it).
- `source_type` is now explicitly required for `init_type = "Import"` (no implicit Git default).
