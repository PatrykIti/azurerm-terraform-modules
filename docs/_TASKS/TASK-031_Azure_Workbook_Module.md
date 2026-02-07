# TASK-031: Azure Workbook module (azurerm_application_insights_workbook)
# FileName: TASK-031_Azure_Workbook_Module.md

**Priority:** Medium  
**Category:** New Module / Monitoring  
**Estimated Effort:** Medium  
**Dependencies:** -  
**Status:** To Do

---

## Audit Subtasks (2026-02-07)

- Scope Status: **GREEN** - Modul pozostaje atomowy (zarzadza tylko `azurerm_application_insights_workbook`), a cross-resource glue jest poza kodem modulu.
- Provider Coverage Status: **GREEN** - Modul eksponuje `storage_container_id` (input + mapowanie + test coverage).
- Overall Status: **YELLOW** - Brak High, ale kilka Medium w pokryciu provider + test harness/docs alignment.

### Naming/Provider-Alignment

- [ ] Potwierdzic i zapisac w tasku capability matrix dla `PRIMARY_RESOURCE` na podstawie realnego schema (`terraform providers schema -json`) zamiast tylko opisu README.
- [x] Utrzymac canonical naming bez rename work: `modules/azurerm_application_insights_workbook`, `module.json:name`, i label zasobu w `modules/azurerm_application_insights_workbook/main.tf`.
- [ ] Dodac `application-insights-workbook` do listy `scopes` w `.github/workflows/pr-validation.yml`, aby `commit_scope` z `modules/azurerm_application_insights_workbook/module.json` byl walidowany.

### Scope boundaries (what to remove/keep)

- [x] Zachowac atomic scope: w `modules/azurerm_application_insights_workbook/main.tf` tylko `azurerm_application_insights_workbook`; nie dodawac RBAC/network/private endpoint resources.
- [x] Utrzymac zaleznosci pomocnicze (LAW, role assignment) wylacznie w examples (`modules/azurerm_application_insights_workbook/examples/complete/main.tf`, `modules/azurerm_application_insights_workbook/examples/secure/main.tf`), nie w module API.
- [x] Doprecyzowac w `modules/azurerm_application_insights_workbook/docs/README.md`, ze `storage_container_id` (po dodaniu wsparcia) pozostaje workbook capability, a RBAC/networking dalej sa out-of-scope.

### Provider coverage gaps for PRIMARY_RESOURCE

- [x] Dodac brakujacy input `storage_container_id` do `modules/azurerm_application_insights_workbook/variables.tf` (z walidacja resource ID) i mapowanie w `modules/azurerm_application_insights_workbook/main.tf`.
- [x] Zaktualizowac docs (`modules/azurerm_application_insights_workbook/README.md`, `modules/azurerm_application_insights_workbook/docs/README.md`, opcjonalnie `modules/azurerm_application_insights_workbook/docs/IMPORT.md`) o nowy argument i intencje jego uzycia.
- [x] Dodac pokrycie testowe dla `storage_container_id` w `modules/azurerm_application_insights_workbook/tests/unit/validation.tftest.hcl` oraz co najmniej jednym Terratest fixture (`tests/fixtures/complete` lub nowy fixture feature-specific).

### Go tests + fixtures checklist gaps

- [x] Dopasowac `modules/azurerm_application_insights_workbook/tests/Makefile` do wzorca addendum: `SHELL := /bin/bash`, `LOG_DIR`, `LOG_TIMESTAMP`, `run_with_log`, ARM<->AZURE env normalization.
- [x] Poprawic `modules/azurerm_application_insights_workbook/tests/run_tests_parallel.sh`: zamienic redirection `2>&1 > "$log_file"` na pipeline z `tee`, aby nie gubic stderr i miec kompletne logi.
- [x] Rozdzielic benchmark execution od test execution w `run_tests_parallel.sh` i `run_tests_sequential.sh` (`Benchmark...` nie powinny byc uruchamiane przez `go test -run`).
- [x] Uporzadkowac fixture `modules/azurerm_application_insights_workbook/tests/fixtures/negative/` do standardu guide (dodac minimalne `variables.tf` i `outputs.tf` albo udokumentowac wyjatek w `tests/README.md`).

### Docs/release/test harness alignment

- [x] Zaktualizowac `modules/azurerm_application_insights_workbook/tests/README.md`, bo obecnie wskazuje nieistniejace targety (`make test-all`, `make test-short`) i nieaktualne nazwy plikow testowych (`module_test.go`).
- [x] Ujednolicic kontrakt env vars miedzy `modules/azurerm_application_insights_workbook/tests/Makefile`, `modules/azurerm_application_insights_workbook/tests/test_helpers.go` i `modules/azurerm_application_insights_workbook/tests/test_config.yaml` (ARM_* + AZURE_* fallback).
- [x] Zsynchronizowac module-level test entrypoints pomiedzy `modules/azurerm_application_insights_workbook/Makefile` i `modules/azurerm_application_insights_workbook/tests/Makefile`, a potem opisac jeden canonical flow w module README.

### Validation commands

- `terraform -chdir=modules/azurerm_application_insights providers schema -json | jq '.provider_schemas["registry.terraform.io/hashicorp/azurerm"].resource_schemas["azurerm_application_insights_workbook"].block.attributes.storage_container_id'`
- `rg -n "storage_container_id" modules/azurerm_application_insights_workbook`
- `terraform -chdir=modules/azurerm_application_insights_workbook test -test-directory=tests/unit`
- `cd modules/azurerm_application_insights_workbook/tests && make test`
- `rg -n "application-insights-workbook" .github/workflows/pr-validation.yml`

---

## Cel

Stworzyc nowy modul `modules/azurerm_application_insights_workbook` zgodny z:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

Modul ma pokrywac wszystkie funkcje dostepne w `azurerm_application_insights_workbook`
oraz zaleznosci bezposrednio zwiazane z workbookiem (tylko to, co jest
na zasobie workbook). AKS jest wzorcem struktury i testow; wszystkie odstepstwa
musza byc jawnie udokumentowane.

---

## Zakres (Provider Resources)

**Primary:**
- `azurerm_application_insights_workbook`

**Powiazane zasoby (w module):**
- brak (workbook nie ma sub-resources w azurerm)

**Potwierdzone w providerze (azurerm 4.57.0, docs):**
- `azurerm_application_insights_workbook`

---

## Zalozenia i decyzje

1) **Atomic scope**  
   Modul zarzadza jednym workbookiem jako primary resource. Brak listy workbookow
   w module (instancje modulu do wielu zasobow).

2) **Brak cross-resource glue**  
   Poza modulem: Application Insights component, Log Analytics Workspace, RBAC,
   role assignments, data source zasobow, storage itp. Pokazujemy je tylko
   w examples jako osobne zasoby.

3) **Security-first**  
   Bezpieczne defaulty i jawne wiadomosci o ryzykach w `SECURITY.md`.
   Szczegolny nacisk na `source_id`, `identity` i poprawny `data_json`.

4) **Spojny styl**  
   Walidacje w `variables.tf`, zaleznosci cross-field jako `lifecycle` preconditions
   w `main.tf`. Nazwy zgodne z guide (no `this`, no skroty).

---

## Feature matrix (musi byc pokryty)

- name (UUID), resource_group_name, location
- display_name, data_json
- optional: description, category, source_id
- tags + timeouts
- identity (SystemAssigned/UserAssigned/SystemAssigned, UserAssigned)
- outputs: id, name, location, resource_group_name, identity

---

## Zakres i deliverables

### TASK-031-1: Discovery / feature inventory

**Cel:** Potwierdzic pelny zakres funkcji provider `azurerm` dla workbooka.

**Do zrobienia:**
- Sprawdzic schema provider `azurerm` (doc lub `terraform providers schema -json`).
- Potwierdzic pola workbooka: `display_name`, `data_json`, `description`, `category`, `source_id`, `tags`.
- Potwierdzic dozwolone wartosci `category` (jesli sa enumerowane).
- Potwierdzic zasady identity (allowed `type`, wymagania `identity_ids`).
- Potwierdzic wymog UUID dla `name` i czy musi byc znany w czasie plan.
- Zaktualizowac listy walidacji, preconditions i examples na bazie realnych pol.

---

### TASK-031-2: Scaffold modulu + pliki bazowe

**Cel:** Stworzyc pelna strukture modulu zgodna z guide.

**Checklist:**
- [ ] `modules/azurerm_application_insights_workbook/` utworzony przez
      `scripts/create-new-module.sh` (wymagane).
- [ ] `module.json`:
  - name: `azurerm_application_insights_workbook`
  - commit_scope: `application-insights-workbook`
  - tag_prefix: `AIWBv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] `.releaserc.js`, `.terraform-docs.yml`, `Makefile`, `generate-docs.sh`
      zgodne z AKS.
- [ ] Pliki bazowe: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`,
      `VERSIONING.md`, `SECURITY.md`, `docs/IMPORT.md`.

---

### TASK-031-3: Core resource `azurerm_application_insights_workbook`

**Cel:** Implementacja pelnego API workbooka w `main.tf` + walidacje w `variables.tf`.

**Zakres (przykladowy podzial inputow):**
- **core**: `name`, `resource_group_name`, `location`, `display_name`, `data_json`, `tags`
- **optional**: `description`, `category`, `source_id`
- **identity**: `type`, `identity_ids`
- **timeouts** (optional)

**Walidacje i preconditions (must-have):**
- `name` jako UUID (regex) i znany na etapie planu (statyczny w examples).
- `display_name` non-empty.
- `data_json` musi byc poprawnym JSON (np. `can(jsondecode(...))`).
- `category` w dozwolonym zbiorze (z discovery).
- `source_id` (jesli podane) zgodny z formatem Azure Resource ID.
- `identity.type` tylko `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned`.
- `identity_ids` wymagane tylko gdy `type` zawiera `UserAssigned`.

**Implementation notes:**
- `locals` dla flag i map wynikowych.
- `lifecycle` preconditions dla regul cross-field.
- Nazwy zasobow i iteratorow zgodne z guide.

---

### TASK-031-4: Dokumentacja modulu

**Cel:** Kompletne docs zgodne z MODULE_GUIDE.

**Do zrobienia:**
- `README.md` z wymaganymi markerami i sekcjami (Module Documentation, Security Considerations).
- `docs/README.md`:
  - Overview, Managed Resources, Usage Notes
  - Out-of-scope zasoby (Application Insights component, Log Analytics Workspace, RBAC).
- `docs/IMPORT.md` wg AKS (import blocks + ID collection).
- `SECURITY.md`:
  - posture (data_json, source_id, identity)
  - secure example
  - checklist i typowe bledy
- `CONTRIBUTING.md` i `VERSIONING.md` zgodne z `module.json`.

---

### TASK-031-5: Examples (basic/complete/secure + feature-specific)

**Cel:** Przyklady zgodne z guide, uruchamialne lokalnie.

**Wymagane:**
- `examples/basic`: minimalny workbook bez `source_id` i bez identity.
- `examples/complete`: workbook z `category`, `description`, `source_id`, `identity`, `tags`.
- `examples/secure`: workbook z user-assigned identity + RBAC do zrodla danych (poza modulem).

**Feature-specific (propozycje):**
- `examples/workbook-identity`
- `examples/workbook-source-id`

**Wymagania wspolne:**
- `source = "../.."`, stale nazwy, `README.md` + `.terraform-docs.yml`.
- `name` workbooka jako statyczny UUID (bez randomizacji).
- Zasoby pomocnicze (AI/LAW/RBAC) tworzone lokalnie w example.

---

### TASK-031-6: Testy (unit + integration + negative)

**Cel:** Zgodnosc z `docs/TESTING_GUIDE`.

**Unit tests (tftest.hcl):**
- walidacje UUID dla `name`.
- walidacja `data_json` (poprawny JSON).
- walidacja `category`.
- reguly `identity` i `identity_ids`.
- outputs z `try()`.

**Integration / Terratest:**
- fixtures: `basic`, `complete`, `secure`, `workbook-identity`.
- weryfikacja:
  - workbook properties (display_name, category, source_id, tags)
  - identity (type + identity_ids)
  - outputs (id, name, location)

**Negatywne:**
- `name` nie-UUID
- `data_json` nie jest poprawnym JSON
- `identity_ids` bez `UserAssigned`

---

### TASK-031-7: Automatyzacja i release

**Cel:** Spojna automatyzacja i dokumentacja.

**Do zrobienia:**
- `tests/Makefile`, `test_env.sh`, `run_tests_*` jak w AKS.
- `generate-docs.sh` zgodny z guide.
- Aktualizacja `docs/_TASKS/README.md` po wdrozeniu.
- Wpis w `docs/_CHANGELOG/` dla nowego modulu.

---

## Acceptance Criteria

- Modul `modules/azurerm_application_insights_workbook` spelnia layout z MODULE_GUIDE.
- Pokrycie wszystkich funkcji z feature matrix + potwierdzonych w provider schema.
- README/SECURITY/IMPORT/CONTRIBUTING/VERSIONING kompletne i spojne.
- Examples basic/complete/secure + feature-specific gotowe i uruchamialne.
- Testy unit + integration + negative przechodza lokalnie.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md` (status + statystyki)
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-application-insights-workbook.md`
- `modules/README.md` (nowy modul w tabeli AzureRM)
- `README.md` (badges + tabela "Available Modules")
