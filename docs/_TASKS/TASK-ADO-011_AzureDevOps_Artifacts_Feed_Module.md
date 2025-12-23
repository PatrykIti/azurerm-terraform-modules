# TASK-ADO-011: Azure DevOps Artifacts Feed Module
# FileName: TASK-ADO-011_AzureDevOps_Artifacts_Feed_Module.md

**Priority:** 🟡 Medium
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-001
**Status:** ⏳ **To Do**

---

## Overview

Moduł do zarządzania feedami artefaktów + retention + permissions.

## Scope (Provider Resources)

- `azuredevops_feed`
- `azuredevops_feed_permission`
- `azuredevops_feed_retention_policy`

## Module Design

### Inputs

- feeds (list(object)): name, project_id (opcjonalnie), description.
- feed_permissions (list(object)): feed_id, principal_descriptor, permissions.
- feed_retention_policies (list(object)): feed_id, days_to_keep, count_limit.

### Outputs

- feed_ids
- feed_urls

### Notes

- Feed może być project-scoped lub org-scoped - zaprojektować wejścia tak, by wspierały oba.

## Examples

- basic: feed projektowy bez retention.
- complete: feed + retention + permissions.
- secure: retention limit + ograniczenia dostępu.

## Tests

- Unit: walidacje zmiennych, typy, wymagane pola.
- Integration: create/update/delete w realnym ADO (env: AZDO_ORG_SERVICE_URL, AZDO_PERSONAL_ACCESS_TOKEN).
- Negative: błędne kombinacje (np. brak project_id tam gdzie wymagany).

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-<module>.md`

## Acceptance Criteria

- Moduł `modules/azuredevops_artifacts_feed` zgodny z wzorcem `modules/azurerm_kubernetes_cluster/`.
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
