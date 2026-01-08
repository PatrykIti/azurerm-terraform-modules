# TASK-ADO-038: Azure DevOps User Entitlement Module Compliance Fixes
# FileName: TASK-ADO-038_AzureDevOps_User_Entitlement_Module_Compliance_Fixes.md

**Priority:** 🔴 High  
**Category:** Azure DevOps Modules  
**Estimated Effort:** Medium  
**Dependencies:** docs/MODULE_GUIDE, docs/TESTING_GUIDE, docs/TERRAFORM_BEST_PRACTICES_GUIDE.md, modules/azuredevops_group (tests baseline)  
**Status:** 🟡 To Do

---

## Overview

Align `modules/azuredevops_user_entitlement` z repo standardami (MODULE_GUIDE, TESTING_GUIDE, TERRAFORM_BEST_PRACTICES) i wzorcem `azuredevops_group`. Usunąć antywzorce (for_each na głównym zasobie), uzupełnić przykłady/fixture’y/testy i naprawić dokumentację tak, aby inputy, testy i kod były spójne.

## Obecne luki

- Główny zasób używa `for_each` na liście; iteracja ma być w konfiguracji konsumenta, nie w module (pojedynczy zasób jak w `azuredevops_group`).
- Testy Go to placeholdery (`t.Skip`), brak `t.Parallel`, etapów `test_structure` i `testing.Short()` w integration/performance.
- Struktura testów niekompletna: tylko `fixtures/basic`, brak `complete`/`secure`/`negative`, brak `test_outputs/` i README w fixture’ach; `tests/Makefile`/skrypty uruchamiają tylko `terraform test`.
- Testy unit mają tylko defaults/validation; brak `naming` i `outputs`, walidacje słabo pokryte (licencje/źródła/komunikaty).
- `tests/README.md` twierdzi, że są tylko unit testy i brak Terratest, co jest sprzeczne ze stanem repo i wymaganiami.
- `docs/README.md` błędnie wskazuje, że `origin_id` jest wymagane; zmienne pozwalają na `principal_name` lub `origin+origin_id`.
- Przykłady/dokumentacja wymagają odświeżenia po zmianie API (pojedynczy obiekt zamiast listy/for_each) i regeneracji terraform-docs.

## Zakres

- Module: `modules/azuredevops_user_entitlement/`
- Examples: `modules/azuredevops_user_entitlement/examples/*`
- Tests: `modules/azuredevops_user_entitlement/tests/`
- Repo docs: `docs/_TASKS/README.md`, `docs/_CHANGELOG/*` (indeks + nowy wpis)

## Dokumenty do aktualizacji

### W module
- `modules/azuredevops_user_entitlement/README.md` (inputs/przykłady/usunięcie for_each, terraform-docs)
- `modules/azuredevops_user_entitlement/docs/README.md` (opis wymagań selectorów)
- `modules/azuredevops_user_entitlement/tests/README.md`
- `modules/azuredevops_user_entitlement/examples/*/README.md` i `.terraform-docs.yml` (w razie potrzeby)

### Repozytoryjne
- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md` + nowy wpis w `docs/_CHANGELOG/`

## Work Items

- **API modułu:** Usuń `for_each` z `azuredevops_user_entitlement.user_entitlement`; model pojedynczego obiektu wejściowego (konsument iteruje). Zaktualizuj zmienne, lokale, wyjścia, przykłady i dokumentację, odwzorowując wzorzec z `azuredevops_group`.
- **Walidacje:** Utrzymaj reguły selektora (albo `principal_name`, albo `origin+origin_id`) i doprecyzuj komunikaty; waliduj listy licencji/źródeł; udokumentuj logikę klucza (explicit key vs principal vs origin_id).
- **Przykłady:** Odśwież `basic|complete|secure` do nowego kształtu wejścia, dodaj `.terraform-docs.yml`, stabilne nazwy i sekcję cleanup; wygeneruj READMEs.
- **Fixtures:** Dodaj `tests/fixtures/complete`, `tests/fixtures/secure`, `tests/fixtures/negative` z `main.tf|variables.tf|outputs.tf` i README w katalogach; deterministyczne klucze.
- **Testy unit:** Dodaj `tests/unit/naming.tftest.hcl` i `tests/unit/outputs.tftest.hcl`; rozszerz walidacje (niepoprawne selektory, puste key/principal/origin_id, błędne license/source).
- **Testy Go:** Zastąp placeholdery pełnym Terratestem z etapami `test_structure` (`setup/deploy/validate/cleanup`), `t.Parallel()`, short-mode w integration/performance, fixture’y basic/complete/secure + negative validation.
- **Helpery i orkiestracja:** Dodaj walidację env i wspólne opcje w `tests/test_helpers.go`; wyrównaj `tests/Makefile`, `run_tests_parallel.sh`, `run_tests_sequential.sh` i `test_config.yaml` do `azuredevops_group` (suites dla basic/complete/secure/validation/integration, wymagane env vars). Dodaj `tests/test_outputs/.gitkeep` i dopasuj `.gitignore`.
- **Dokumentacja:** Napraw sekcję Inputs w `docs/README.md` (reguły selectorów), wygeneruj README modułu terraform-docs, dopisz notatkę o braku for_each w module.
- **Changelog:** Dodaj wpis w `docs/_CHANGELOG/` i zaktualizuj indeks.

## Wymagania środowiskowe testów

- Wymagane env do Terratest: `AZDO_ORG_SERVICE_URL`, `AZDO_PERSONAL_ACCESS_TOKEN` oraz principal names/origin IDs użyte w fixture’ach (opisać w `tests/README.md` i `test_env.sh`).
- Testy mają skipować lub fail-fast przy brakujących zmiennych; integration/performance muszą respektować `testing.Short()`.

## Kryteria akceptacji

- Główny zasób nie używa `for_each`; moduł zarządza pojedynczym entitlementem, a iteracja jest w konfiguracji konsumenta.
- READMEs modułu/przykładów dokładnie opisują reguły selektora; znaczniki terraform-docs odświeżone.
- `tests/` spełnia TESTING_GUIDE: fixture’y `basic|complete|secure|negative`, unit `defaults|naming|outputs|validation`, `.gitignore`, `test_outputs/`.
- Terratest używa `test_structure`, `t.Parallel()` i short-mode; test walidacyjny obejmuje negative fixture.
- `tests/README.md` i `test_config.yaml` opisują testy Go + Terraform oraz wymagane env vars.
- Dodany wpis w changelogu i zaktualizowany indeks w `docs/_CHANGELOG/README.md`.

## Checklist implementacyjny

- [ ] Refaktoryzacja modułu do pojedynczego zasobu (bez for_each) + aktualizacja outputs.
- [ ] Odświeżenie przykładów (`basic|complete|secure`) i regeneracja terraform-docs.
- [ ] Dodanie fixture’ów (`complete|secure|negative`) z README i deterministycznymi kluczami.
- [ ] Dodanie unit testów dla naming/outputs i rozszerzenie walidacji.
- [ ] Implementacja pełnego Terratest (main/integration/performance) z test_structure i guardami env/short.
- [ ] Aktualizacja helperów, Makefile, skryptów uruchomieniowych i test_config zgodnie z `azuredevops_group`.
- [ ] Dodanie `tests/test_outputs/.gitkeep` i wyrównanie `.gitignore`.
- [ ] Aktualizacja READMEs modułu/doksów oraz changelog (wpis + indeks) i statystyk w `docs/_TASKS/README.md`.
