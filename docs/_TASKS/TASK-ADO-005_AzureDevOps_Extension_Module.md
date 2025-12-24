# TASK-ADO-005: Azure DevOps Extension Module
# FileName: TASK-ADO-005_AzureDevOps_Extension_Module.md

**Priority:** 🟡 Medium
**Category:** Azure DevOps Modules
**Estimated Effort:** Small
**Dependencies:** —
**Status:** ✅ **Done** (2025-12-24)

---

## Overview

Moduł do instalacji/zarządzania rozszerzeniami Marketplace na poziomie organizacji.

## Scope (Provider Resources)

- `azuredevops_extension`

## Module Design

### Inputs

- extensions (list(object)): publisher_id, extension_id, version (opcjonalnie).

### Outputs

- extension_ids

### Notes

- Org-level. Dobry kandydat na szybki moduł o małej złożoności.

## Examples

- basic: instalacja jednego rozszerzenia.
- complete: kilka rozszerzeń z pinem wersji.
- secure: tylko zatwierdzone rozszerzenia (whitelist).

## Tests

- Unit: walidacje zmiennych, typy, wymagane pola.
- Integration: create/update/delete w realnym ADO (env: AZDO_ORG_SERVICE_URL, AZDO_PERSONAL_ACCESS_TOKEN, AZDO_EXTENSION_PUBLISHER_ID, AZDO_EXTENSION_ID).
- Negative: błędne kombinacje (np. brak publisher_id/extension_id, duplikaty).

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-<module>.md`

## Acceptance Criteria

- Moduł `modules/azuredevops_extension` zgodny z wzorcem `modules/azurerm_kubernetes_cluster/`.
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
