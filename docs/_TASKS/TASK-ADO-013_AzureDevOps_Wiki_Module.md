# TASK-ADO-013: Azure DevOps Wiki Module
# FileName: TASK-ADO-013_AzureDevOps_Wiki_Module.md

**Priority:** 🟡 Medium
**Category:** Azure DevOps Modules
**Estimated Effort:** Small
**Dependencies:** TASK-ADO-001
**Status:** ✅ **Done** (2025-12-24)

---

## Overview

Zarządzanie wiki projektową i stronami wiki.

## Scope (Provider Resources)

- `azuredevops_wiki`
- `azuredevops_wiki_page`

## Module Design

### Inputs

- project_id (string).
- wikis (list(object)): name, type, repository_id (opcjonalnie).
- wiki_pages (list(object)): wiki_id, path, content, version.

### Outputs

- wiki_ids
- wiki_page_paths

### Notes

- Wiki może być repo-based - potrzebny repository_id.

## Examples

- basic: projektowa wiki + strona startowa.
- complete: kilka stron i struktura katalogów.
- secure: brak danych wrażliwych w treści, kontrola dostępu.

## Tests

- Unit: walidacje zmiennych, typy, wymagane pola.
- Integration: create/update/delete w realnym ADO (env: AZDO_ORG_SERVICE_URL, AZDO_PERSONAL_ACCESS_TOKEN).
- Negative: błędne kombinacje (np. brak project_id tam gdzie wymagany).

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-<module>.md`

## Acceptance Criteria

- Moduł `modules/azuredevops_wiki` zgodny z wzorcem `modules/azurerm_kubernetes_cluster/`.
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
