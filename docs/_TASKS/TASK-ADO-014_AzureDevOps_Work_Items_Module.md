# TASK-ADO-014: Azure DevOps Work Items Module
# FileName: TASK-ADO-014_AzureDevOps_Work_Items_Module.md

**Priority:** 🟡 Medium
**Category:** Azure DevOps Modules
**Estimated Effort:** Large
**Dependencies:** TASK-ADO-001, TASK-ADO-002 (opcjonalnie)
**Status:** ✅ **Done** (2025-12-24)

---

## Overview

Procesy, work items, query oraz permissions dla area/iteration/tagging w jednym module.

## Scope (Provider Resources)

- `azuredevops_workitem`
- `azuredevops_workitemquery`
- `azuredevops_workitemquery_folder`
- `azuredevops_workitemquery_permissions`
- `azuredevops_workitemtrackingprocess_process`
- `azuredevops_area_permissions`
- `azuredevops_iteration_permissions`
- `azuredevops_tagging_permissions`

## Module Design

### Inputs

- project_id (string).
- processes (list(object)): name, description, parent_process_type.
- work_items (list(object)): project_id, type, fields, relations.
- query_folders (list(object)): project_id, path, description.
- queries (list(object)): project_id, path, wiql.
- query_permissions (list(object)): query_id, principal_descriptor, permissions.
- area_permissions / iteration_permissions / tagging_permissions (list(object)): node_id, principal_descriptor, permissions.

### Outputs

- process_ids
- work_item_ids
- query_ids

### Notes

- Uprawnienia wymagają descriptors z modułu identity.

## Examples

- basic: proces + jeden work item.
- complete: proces + queries + permissions.
- secure: ograniczenia tagging/area/iteration.

## Tests

- Unit: walidacje zmiennych, typy, wymagane pola.
- Integration: create/update/delete w realnym ADO (env: AZDO_ORG_SERVICE_URL, AZDO_PERSONAL_ACCESS_TOKEN).
- Negative: błędne kombinacje (np. brak project_id tam gdzie wymagany).

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-<module>.md`

## Acceptance Criteria

- Moduł `modules/azuredevops_work_items` zgodny z wzorcem `modules/azurerm_kubernetes_cluster/`.
- Pokrycie wszystkich wskazanych resources z listy Scope.
- README generowany przez terraform-docs + kompletne examples.
- Testy unit + integration + negative dodane i przechodzą.
- Wpisy w docs/_TASKS i docs/_CHANGELOG zaktualizowane.

## Implementation Checklist

- [x] Scaffold modułu (scripts/create-new-module.sh lub manualnie) + module.json
- [x] versions.tf z azuredevops 1.12.2
- [x] variables.tf z walidacjami + domyślne bezpieczne wartości
- [x] main.tf (for_each dla list, dynamic blocks gdzie potrzebne)
- [x] outputs.tf (w tym sensitive gdzie wymagane)
- [x] examples/basic + complete + secure
- [x] tests/fixtures + unit + terratest
- [x] make docs + update README
