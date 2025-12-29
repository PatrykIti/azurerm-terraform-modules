# TASK-ADO-010: Azure DevOps Variable Groups Module
# FileName: TASK-ADO-010_AzureDevOps_Variable_Groups_Module.md

**Priority:** 🟡 Medium
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-001
**Status:** ✅ **Done** (2025-12-24)

---

## Overview

Variable Groups + permissions/library permissions w jednym module.

## Scope (Provider Resources)

- `azuredevops_variable_group`
- `azuredevops_variable_group_permissions`
- `azuredevops_library_permissions`

## Module Design

### Inputs

- project_id (string).
- variable_groups (list(object)): name, description, allow_access, variables(map) z flagami secret.
- variable_group_permissions (list(object)): group_id, principal_descriptor, permissions.
- library_permissions (list(object)): project_id, principal_descriptor, permissions.

### Outputs

- variable_group_ids

### Notes

- Sekrety: użyć sensitive = true w outputs/inputs.

## Examples

- basic: jeden variable group z jawnymi zmiennymi.
- complete: kilka grup + permissions + allow_access.
- secure: sekrety + ograniczenia dostępu.

## Tests

- Unit: walidacje zmiennych, typy, wymagane pola.
- Integration: create/update/delete w realnym ADO (env: AZDO_ORG_SERVICE_URL, AZDO_PERSONAL_ACCESS_TOKEN).
- Negative: błędne kombinacje (np. brak project_id tam gdzie wymagany).

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-<module>.md`

## Acceptance Criteria

- Moduł `modules/azuredevops_variable_groups` zgodny z wzorcem `modules/azurerm_kubernetes_cluster/`.
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
