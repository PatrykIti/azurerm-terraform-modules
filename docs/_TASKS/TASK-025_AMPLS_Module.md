# TASK-025: Azure Monitor Private Link Scope (AMPLS) module
# FileName: TASK-025_AMPLS_Module.md

**Priority:** High  
**Category:** New Module / Monitoring  
**Estimated Effort:** Medium  
**Dependencies:** -  
**Status:** To Do

---

## Cel

Stworzyc nowy modul `modules/azurerm_monitor_private_link_scope` zgodny z:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

Modul ma pokrywac wszystkie funkcje dostepne w `azurerm_monitor_private_link_scope`
oraz powiazane sub-resources potrzebne do pelnego zarzadzania AMPLS.
AKS jest wzorcem struktury i testow; wszystkie odstepstwa musza byc jawnie
udokumentowane.

---

## Zakres (Provider Resources)

**Primary:**
- `azurerm_monitor_private_link_scope`

**Powiazane zasoby (w module):**
- `azurerm_monitor_private_link_scoped_service`
- `azurerm_monitor_diagnostic_setting`

**Potwierdzone w providerze (azurerm 4.57.0, docs):**
- `azurerm_monitor_private_link_scope`
- `azurerm_monitor_private_link_scoped_service`

---

## Zalozenia i decyzje

1) **Atomic scope**  
   Modul zarzadza jednym AMPLS jako primary resource. Dodatkowe zasoby tylko
   wtedy, gdy sa bezposrednio powiazane z AMPLS (scoped services, diagnostic settings).

2) **Brak cross-resource glue**  
   Poza modulem: private endpoints, Private DNS Zone + VNet links, RBAC/role
   assignments, networking. Pokazujemy je tylko w examples jako osobne zasoby.

3) **Security-first**  
   Secure defaults gdzie to mozliwe. `ingestion_access_mode` i `query_access_mode`
   ustawiane jawnie. Wszystkie ryzyka opisane w `SECURITY.md`.

4) **Spojny styl**  
   Listy obiektow + `for_each` po `name`, walidacje w `variables.tf`, zaleznosci
   cross-field jako `lifecycle` preconditions w `main.tf`.

---

## Feature matrix (musi byc pokryty)

- name + RG
- `ingestion_access_mode` (`PrivateOnly` / `Open`)
- `query_access_mode` (`PrivateOnly` / `Open`)
- tags + timeouts
- scoped services (Log Analytics, Application Insights, DCE, etc.)
- diagnostic settings (log/metric categories)

---

## Zakres i deliverables

### TASK-025-1: Discovery / feature inventory

**Cel:** Potwierdzic pelny zakres funkcji provider `azurerm` dla AMPLS i scoped services.

**Do zrobienia:**
- Sprawdzic schema provider `azurerm` (doc lub `terraform providers schema -json`).
- Potwierdzic dozwolone wartosci `ingestion_access_mode` i `query_access_mode`.
- Spisac finalny zestaw pol i ograniczen (allowed values, required combos).
- Zaktualizowac listy walidacji, preconditions i examples na bazie realnych pol.

---

### TASK-025-2: Scaffold modulu + pliki bazowe

**Cel:** Stworzyc pelna strukture modulu zgodna z guide.

**Checklist:**
- [ ] `modules/azurerm_monitor_private_link_scope/` utworzony przez
      `scripts/create-new-module.sh` (wymagane).
- [ ] `module.json`:
  - name: `azurerm_monitor_private_link_scope`
  - commit_scope: `monitor-private-link-scope`
  - tag_prefix: `AMPLSv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] `.releaserc.js`, `.terraform-docs.yml`, `Makefile`, `generate-docs.sh`
      zgodne z AKS.
- [ ] Pliki bazowe: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`,
      `VERSIONING.md`, `SECURITY.md`, `docs/IMPORT.md`.

---

### TASK-025-3: Core resource `azurerm_monitor_private_link_scope`

**Cel:** Implementacja pelnego API AMPLS w `main.tf` + walidacje w `variables.tf`.

**Zakres (przykladowy podzial inputow):**
- **core**: `name`, `resource_group_name`, `location` (jesli wspierane), `tags`
- **access**: `ingestion_access_mode`, `query_access_mode`
- **timeouts** (optional)

**Walidacje i preconditions (must-have):**
- Nazwa zgodna z rules Azure (length + regex).
- `ingestion_access_mode` w dozwolonym zbiorze.
- `query_access_mode` w dozwolonym zbiorze.

---

### TASK-025-4: Sub-resources (scoped services)

**Cel:** Pelne wsparcie `azurerm_monitor_private_link_scoped_service`.

**Inputs (propozycje):**
- `scoped_services`: list(object({ name, linked_resource_id }))

**Wymagania:**
- `for_each` po `name` + walidacja unikalnosci.
- Walidacja `linked_resource_id` (format Azure resource ID).
- Zaleznosc na AMPLS.

---

### TASK-025-5: Diagnostic settings (inline, AKS pattern)

**Cel:** Wbudowane `azurerm_monitor_diagnostic_setting` dla AMPLS.

**Do zrobienia:**
- `diagnostic_settings` input (lista obiektow) jak w AKS.
- `data.azurerm_monitor_diagnostic_categories` + filtracja kategorii.
- `areas` -> mapowanie na log/metric categories (lub default `all`).
- `diagnostic_settings_skipped` output jak w AKS.

---

### TASK-025-6: Dokumentacja modulu

**Cel:** Kompletne docs zgodne z MODULE_GUIDE.

**Do zrobienia:**
- `README.md` z wymaganymi markerami i sekcjami (Module Documentation, Security Considerations).
- `docs/README.md`:
  - Overview, Managed Resources, Usage Notes
  - Out-of-scope zasoby (private endpoints, DNS zones, RBAC).
- `docs/IMPORT.md` wg AKS (import blocks + ID collection).
- `SECURITY.md`:
  - posture (ingestion/query access)
  - secure example
  - checklist i typowe bledy
- `CONTRIBUTING.md` i `VERSIONING.md` zgodne z `module.json`.

---

### TASK-025-7: Examples (basic/complete/secure + feature-specific)

**Cel:** Przyklady zgodne z guide, uruchamialne lokalnie.

**Wymagane:**
- `examples/basic`: AMPLS bez scoped services.
- `examples/complete`: AMPLS + scoped services (LAW + App Insights + DCE).
- `examples/secure`: PrivateOnly dla ingestion/query + private endpoint (poza modulem).

**Feature-specific (propozycje):**
- `examples/scoped-services`

**Wymagania wspolne:**
- `source = "../.."`, stale nazwy, `README.md` + `.terraform-docs.yml`.
- Zasoby pomocnicze (LAW, App Insights, DCE) tworzone lokalnie w example.

---

### TASK-025-8: Testy (unit + integration + negative)

**Cel:** Zgodnosc z `docs/TESTING_GUIDE`.

**Unit tests (tftest.hcl):**
- walidacje nazw i dozwolonych access modes.
- unikalnosc nazw scoped services.
- outputs z `try()`.

**Integration / Terratest:**
- fixtures: `basic`, `complete`, `secure`, `scoped-services`.
- weryfikacja:
  - AMPLS properties (access modes)
  - scoped services (count + linked_resource_id)
  - diag settings (log/metric categories)

**Negatywne:**
- zly format nazwy
- invalid access mode
- scoped service bez linked_resource_id

---

### TASK-025-9: Automatyzacja i release

**Cel:** Spojna automatyzacja i dokumentacja.

**Do zrobienia:**
- `tests/Makefile`, `test_env.sh`, `run_tests_*` jak w AKS.
- `generate-docs.sh` zgodny z guide.
- Aktualizacja `docs/_TASKS/README.md` po wdrozeniu.
- Wpis w `docs/_CHANGELOG/` dla nowego modulu.

---

## Acceptance Criteria

- Modul `modules/azurerm_monitor_private_link_scope` spelnia layout z MODULE_GUIDE.
- Pokrycie wszystkich funkcji z feature matrix + potwierdzonych w provider schema.
- README/SECURITY/IMPORT/CONTRIBUTING/VERSIONING kompletne i spojne.
- Examples basic/complete/secure + feature-specific gotowe i uruchamialne.
- Testy unit + integration + negative przechodza lokalnie.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md` (status + statystyki)
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ampls.md`
- `modules/README.md` (nowy modul w tabeli AzureRM)
- `README.md` (badges + tabela "Available Modules")
