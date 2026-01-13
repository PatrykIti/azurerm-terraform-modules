# TASK-ADO-037: Azure DevOps Security Role Assignment Docs and Tests Alignment
# FileName: TASK-ADO-037_AzureDevOps_SecurityRole_Assignment_Docs_and_Tests_Alignment.md

**Priority:** 🟡 Medium  
**Category:** Azure DevOps Modules  
**Estimated Effort:** Medium  
**Dependencies:** docs/MODULE_GUIDE, docs/TESTING_GUIDE, docs/TERRAFORM_BEST_PRACTICES_GUIDE.md, modules/azuredevops_group (tests baseline)  
**Status:** ✅ **Done** (2026-01-08)

---

## Overview

Ujednolić dokumentację i testy modułu `modules/azuredevops_securityrole_assignment` z faktycznym API (pojedyncze przypisanie roli, bez iteracji). Naprawić przykłady, import guide i orkiestrację testów tak, aby były zgodne z repo standardami i nie sugerowały listowego interfejsu ani map outputów.

## Current Gaps

- README + docs/README + docs/IMPORT opisują listowy input `securityrole_assignments` i mapę outputów; realny moduł ma pojedyncze zmienne i pojedynczy output.
- Examples README są niespójne (mapa outputów, brak provider/resource w tabelach) i nie odzwierciedlają rzeczywistego API.
- Tests: tylko fixture `basic`, minimalne unit testy; Go testy to placeholdery, Makefile/skrypty/test_config.yaml nie odzwierciedlają Terratestów ani struktury jak w `modules/azuredevops_group/tests`; brak `test_outputs/`.

## Scope

- Module docs: `modules/azuredevops_securityrole_assignment/README.md`, `docs/README.md`, `docs/IMPORT.md`
- Examples: `modules/azuredevops_securityrole_assignment/examples/{basic,complete,secure}/*`
- Tests: `modules/azuredevops_securityrole_assignment/tests/**/*`
- Repo tasks index: `docs/_TASKS/README.md`

## Docs to Update

### In-Module
- `modules/azuredevops_securityrole_assignment/README.md`
- `modules/azuredevops_securityrole_assignment/docs/README.md`
- `modules/azuredevops_securityrole_assignment/docs/IMPORT.md`
- `modules/azuredevops_securityrole_assignment/examples/*/README.md` (+ regen terraform-docs)

### Repo-Level
- `docs/_TASKS/README.md`

## Work Items

- **Usage docs:** Przepisać Usage w module README na pojedyncze argumenty (`scope`, `resource_id`, `role_name`, `identity_id`); poprawić listę przykładów i sekcję outputs tak, aby zgadzały się z kodem.
- **Docs/IMPORT:** Uprościć opis do pojedynczego zasobu; import block bez `for_each`/kluczy (`to = module.azuredevops_securityrole_assignment.azuredevops_securityrole_assignment.securityrole_assignment`).
- **Examples:** Ujednolicić README (providers/resources, poprawne outputy), utrzymać `.terraform-docs.yml`, w razie potrzeby dostosować opisy i cleanup.
- **Tests layout:** Dodać `fixtures/complete` i `fixtures/secure` (opcjonalnie `negative`), `test_outputs/.gitkeep`, rozszerzyć unit `.tftest.hcl` o walidacje/outputy zgodne z pojedynczym API.
- **Go tests & orchestration:** Zastąpić placeholdery realnymi (lub świadomie skipowanymi) testami Terratest ze stage’ami test-structure i scenariuszami basic/complete/secure; zaktualizować `tests/Makefile`, `run_tests_*`, `test_config.yaml`, `tests/README.md`, `test_env.sh`, `.gitignore` według wzorca `modules/azuredevops_group/tests`.
- **Docs regen:** Po zmianach uruchomić terraform-docs dla modułu i przykładów.

## Test Environment Requirements

- `AZDO_ORG_SERVICE_URL`
- `AZDO_PERSONAL_ACCESS_TOKEN`
- Identyfikatory testowych obiektów ADO użytych w fixtures (np. projekt/identity ID per scenario).

## Acceptance Criteria

- Dokumentacja modułu, docs/README, IMPORT i wszystkie READMEs przykładów odzwierciedlają pojedynczy interfejs i poprawne outputy; terraform-docs wygenerowane.
- Tests mają pełną strukturę (fixtures basic/complete/secure, unit tests dla walidacji/outputów, `test_outputs/`, `.gitignore`).
- Go testy nie są placeholderami: używają test-structure stage’ów, `t.Parallel()`, mają check-env i opcjonalny skip dla short-mode; Makefile i skrypty uruchamiają zarówno `terraform test`, jak i Terratest.
- `docs/_TASKS/README.md` zaktualizowany o nowe zadanie i statystyki.

## Implementation Checklist

- [x] Zaktualizować moduł README + docs/README + docs/IMPORT do pojedynczego API.
- [x] Uporządkować README przykładów i zregenerować terraform-docs (module + examples).
- [x] Dodać fixtures `complete`/`secure` (opcjonalnie `negative`) i rozbudować unit tests (walidacje, outputy).
- [x] Zaimplementować/ustawić Terratesty + stage’y test-structure; ujednolicić Makefile/skrypty/test_config/.gitignore/test_outputs.
- [x] Zaktualizować `docs/_TASKS/README.md` (statystyki + wpis To Do).
