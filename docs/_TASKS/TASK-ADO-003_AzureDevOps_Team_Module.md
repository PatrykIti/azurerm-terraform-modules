# TASK-ADO-003: Azure DevOps Team Module
# FileName: TASK-ADO-003_AzureDevOps_Team_Module.md

**Priority:** 🟡 Medium
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-001
**Status:** ✅ **Done** (2025-12-24)

---

## Overview

Moduł zespołów w ramach projektu: tworzenie teamów, przypisywanie członków i adminów.

## Scope (Provider Resources)

- `azuredevops_team`
- `azuredevops_team_members`
- `azuredevops_team_administrators`

## Module Design

### Inputs

- project_id (string).
- teams (map(object)): name (opcjonalnie), description (opcjonalnie).
- team_members (list(object)): team_id lub team_key + member_descriptors + mode.
- team_administrators (list(object)): team_id lub team_key + admin_descriptors + mode.

### Outputs

- team_ids
- team_descriptors
- team_member_ids
- team_administrator_ids

### Notes

- Zależność od modułu project; opcjonalnie od identity (descriptors).

## Examples

- basic: jeden team (opcjonalnie członkowie).
- complete: wiele teamów + członkowie + admini.
- secure: overwrite adminów dla kontrolowanego dostępu.

## Tests

- Unit: walidacje zmiennych, typy, wymagane pola.
- Integration: create/update/delete w realnym ADO (env: AZDO_ORG_SERVICE_URL, AZDO_PERSONAL_ACCESS_TOKEN).
- Negative: błędne kombinacje (np. team_id i team_key jednocześnie).

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-<module>.md`

## Acceptance Criteria

- Moduł `modules/azuredevops_team` zgodny z wzorcem `modules/azurerm_kubernetes_cluster/`.
- Pokrycie wszystkich wskazanych resources z listy Scope.
- README generowany przez terraform-docs + kompletne examples.
- Testy unit + integration + negative dodane i przechodzą.
- Wpisy w docs/_TASKS i docs/_CHANGELOG zaktualizowane.

## Implementation Checklist

- [ ] Scaffold modułu (scripts/create-new-module.sh lub manualnie) + module.json
- [ ] versions.tf z azuredevops 1.12.2
- [ ] variables.tf z walidacjami + domyślne bezpieczne wartości
- [ ] main.tf (for_each dla list, dynamic blocks gdzie potrzebne)
- [ ] outputs.tf (w tym sensitive gdzie wymagane)
- [ ] examples/basic + complete + secure
- [ ] tests/fixtures + unit + terratest
- [ ] make docs + update README
