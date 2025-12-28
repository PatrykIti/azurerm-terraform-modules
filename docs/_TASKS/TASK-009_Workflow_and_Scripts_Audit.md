# TASK-009: Workflow and scripts audit (docs/examples/source updates)
# FileName: TASK-009_Workflow_and_Scripts_Audit.md

**Priority:** 🔴 High  
**Category:** CI/CD / Automation  
**Estimated Effort:** Medium  
**Dependencies:** —  
**Status:** ✅ **Done**

---

## Cel

Zweryfikowac wszystkie workflow i skrypty, ktore modyfikuja README, examples, versions oraz `source`, tak aby zmiany dotyczyly tylko docelowych miejsc. Audit musi uwzgledniac oba providery w repo: `azurerm_*` i `azuredevops_*`.

---

## Kontekst i problemy (do potwierdzenia)

- `modules/*/.releaserc.js` -> `prepareCmd` uzywa `sed` na `examples/**/*.tf` (`source.*=.*"`) i moze podmieniac:
  - `required_providers.*.source` (np. `hashicorp/azurerm`, `microsoft/azuredevops`)
  - `source` innych modulow w examples (np. `azurerm_kubernetes_secrets` -> `azurerm_kubernetes_cluster`)
- `update-module-version.sh` probuje czytac TAG_PREFIX z `.releaserc.js` w starym formacie; w nowym formacie (module.json) prefix nie jest wyciagany.
- `update-root-readme.sh` zaklada tabele i badge sekcje, ktorych nie ma w root README.
- Detekcja modulow w `pr-validation.yml`, `module-ci.yml`, `release-changed-modules.yml` zaklada `azurerm_` prefix i nie obsluguje `azuredevops_*` w scope.
- `create-module-json.sh` i `create-new-module.sh` sa azurerm-centric; brak logiki dla `azuredevops_`.

---

## Zakres i deliverables

### TASK-009-1: Inwentaryzacja

**Status:** ✅ Done (workflow + script mapping in `docs/WORKFLOWS.md`)

- Spisac wszystkie workflow i skrypty, ktore modyfikuja pliki (README/examples/versions/module.json).
- Zmapowac: kto je wywoluje, jakie pliki dotyka, jakie sa marker-y/regex.

### TASK-009-2: Bezpieczna aktualizacja `source` w examples

**Status:** ✅ Done (release now rewrites only `source = "../.."` / `source = "../../"` in examples)

- Zmienic logike w release tak, aby:
  - Podmieniac tylko `source` wskazujace na lokalny modul (`../..` / `../../`) lub tylko blok `module "<module_name>"`.
  - Nie dotykac `required_providers.source` ani innych modulow w examples.
- Dodac szybki "dry-run" lub test diff w `scripts/testing_workflows/` (opcjonalnie).

### TASK-009-3: Provider-aware module detection

**Status:** ✅ Done (workflow detection uses `module.json` commit_scope mapping)

- Rozszerzyc detekcje modulow w workflow o `azuredevops_*`.
- Opcja preferowana: mapowanie `commit_scope` -> modul na podstawie `modules/*/module.json`.

### TASK-009-4: Aktualizacje wersji i README

**Status:** ✅ Done (module + root README updates aligned to current structure)

- `update-module-version.sh` czyta `tag_prefix` z `module.json` (zamiast regex na .releaserc.js).
- `update-root-readme.sh` dostosowac do realnej struktury README lub wylaczyc.
- Ustalic finalny format wersji w module README (z prefixem czy bez).

### TASK-009-5: Przeglad modulow (przyklady)

**Status:** ✅ Done (verified AKS secrets, NSG, Azure DevOps identity examples)

- `modules/azurerm_kubernetes_secrets` (examples z innym modulem w `source`).
- `modules/azurerm_network_security_group` (standardowe `../..`).
- `modules/azuredevops_identity` (drugi provider).

### TASK-009-6: Dokumentacja

**Status:** ✅ Done (updated `docs/WORKFLOWS.md` with script map and catalog)

- Zaktualizowac `docs/WORKFLOWS.md` i/lub `docs/MODULE_GUIDE` o nowy mechanizm podmian `source`.

---

## Definition of Done

- Lista workflow/skryptow + mapowanie zmian gotowe.
- Release nie modyfikuje `required_providers.source` ani cudzych modulow.
- Detekcja modulow dziala dla `azurerm_*` i `azuredevops_*`.
- Dokumentacja opisuje aktualny, bezpieczny flow.
