# TASK-024: Application Insights module (full feature scope)
# FileName: TASK-024_Application_Insights_Module.md

**Priority:** High  
**Category:** New Module / Monitoring  
**Estimated Effort:** Large  
**Dependencies:** -  
**Status:** Done

---

## Cel

Stworzyc nowy modul `modules/azurerm_application_insights` zgodny z:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

Modul ma pokrywac wszystkie funkcje dostepne w `azurerm_application_insights`
oraz powiazane sub-resources potrzebne do pelnego zarzadzania Application Insights.
AKS jest wzorcem struktury i testow; wszystkie odstepstwa musza byc jawnie
udokumentowane.

---

## Zakres (Provider Resources)

**Primary:**
- `azurerm_application_insights`

**Powiazane zasoby (w module):**
- `azurerm_application_insights_api_key`
- `azurerm_application_insights_analytics_item`
- `azurerm_application_insights_web_test`
- `azurerm_application_insights_standard_web_test`
- `azurerm_application_insights_workbook`
- `azurerm_application_insights_smart_detection_rule`
- `azurerm_monitor_diagnostic_setting`

**Potwierdzone w providerze (azurerm 4.57.0, docs):**
- `azurerm_application_insights`
- `azurerm_application_insights_api_key`
- `azurerm_application_insights_analytics_item`
- `azurerm_application_insights_web_test`
- `azurerm_application_insights_standard_web_test`
- `azurerm_application_insights_workbook`
- `azurerm_application_insights_smart_detection_rule`

---

## Zalozenia i decyzje

1) **Atomic scope**  
   Modul zarzadza jednym Application Insights jako primary resource. Dodatkowe
   zasoby tylko wtedy, gdy sa bezposrednio powiazane z AI (api keys, analytics
   items, web tests, workbooks, smart detection rules, diag settings).

2) **Brak cross-resource glue**  
   Poza modulem: private endpoints, Private DNS, RBAC/role assignments,
   Log Analytics workspace, networking glue. Pokazujemy je tylko w examples
   jako osobne zasoby.

3) **Security-first**  
   Secure defaults gdzie to mozliwe. Publiczny dostep (ingestion/query)
   tylko przez jawne inputy. Klucze API jako outputs oznaczone `sensitive`.
   Wszystkie ryzyka opisane w `SECURITY.md`.

4) **Spojny styl**  
   Listy obiektow + `for_each` po `name`, walidacje w `variables.tf`, zaleznosci
   cross-field jako `lifecycle` preconditions w `main.tf`.

---

## Feature matrix (musi byc pokryty)

- application_type + workspace-based configuration (workspace_id)
- retention / sampling / daily data cap
- public ingestion/query toggles
- local authentication toggle
- disable IP masking
- tags + timeouts
- API keys (read/write permissions)
- analytics items (query/function/folder)
- web tests (classic + standard)
- workbooks
- smart detection rules
- diagnostic settings (log/metric categories)

---

## Zakres i deliverables

### TASK-024-1: Discovery / feature inventory

**Cel:** Potwierdzic pelny zakres funkcji provider `azurerm` dla Application Insights i sub-resources.

**Do zrobienia:**
- Sprawdzic schema provider `azurerm` (doc lub `terraform providers schema -json`)
  dla `azurerm_application_insights` i powiazanych zasobow.
- Potwierdzic dokladne nazwy oraz status wsparcia dla:
  - `azurerm_application_insights_workbook`
  - `azurerm_application_insights_standard_web_test`
  - `azurerm_application_insights_smart_detection_rule`
- Spisac finalny zestaw pol i ograniczen (allowed values, required combos).
- Zaktualizowac listy walidacji, preconditions i examples na bazie realnych pol.

---

### TASK-024-2: Scaffold modulu + pliki bazowe

**Cel:** Stworzyc pelna strukture modulu zgodna z guide.

**Checklist:**
- [ ] `modules/azurerm_application_insights/` utworzony przez
      `scripts/create-new-module.sh` (wymagane).
- [ ] `module.json`:
  - name: `azurerm_application_insights`
  - commit_scope: `application-insights`
  - tag_prefix: `APPINSv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] `.releaserc.js`, `.terraform-docs.yml`, `Makefile`, `generate-docs.sh`
      zgodne z AKS.
- [ ] Pliki bazowe: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`,
      `VERSIONING.md`, `SECURITY.md`, `docs/IMPORT.md`.

---

### TASK-024-3: Core resource `azurerm_application_insights`

**Cel:** Implementacja pelnego API AI w `main.tf` + walidacje w `variables.tf`.

**Zakres (przykladowy podzial inputow):**
- **core**: `name`, `resource_group_name`, `location`, `tags`
- **type**: `application_type`
- **workspace**: `workspace_id` (workspace-based)
- **retention/quotas**: `retention_in_days`, `daily_data_cap_in_gb`,
  `daily_data_cap_notifications_disabled`, `sampling_percentage`
- **access**: `internet_ingestion_enabled`, `internet_query_enabled`,
  `local_authentication_disabled`
- **privacy**: `disable_ip_masking`
- **timeouts** (optional)

**Walidacje i preconditions (must-have):**
- Nazwa zgodna z rules Azure (length + regex).
- `application_type` w dozwolonym zbiorze.
- `sampling_percentage` w zakresie 0-100.
- `retention_in_days` w dozwolonym zakresie (wg provider schema).
- `daily_data_cap_in_gb` dodatnie lub null.

**Implementation notes:**
- `locals` dla flag i map wynikowych.
- `lifecycle` preconditions dla regul cross-field.
- Nazwy zasobow i iteratorow zgodne z guide (no `this`, no skroty).

---

### TASK-024-4: Sub-resources (API keys, analytics items, web tests, workbooks, smart detection)

**Cel:** Pelne wsparcie sub-resources zwiazanych z AI.

**Inputs (propozycje):**
- `api_keys`: list(object({ name, read_permissions?, write_permissions? }))
- `analytics_items`: list(object({ name, content, scope, type }))
- `web_tests`: list(object({ name, kind, frequency, timeout, enabled, geo_locations, configuration }))
- `standard_web_tests`: list(object({ name, geo_locations, request }))
- `workbooks`: list(object({ name, display_name, data_json, tags?, identity? }))
- `smart_detection_rules`: list(object({ name, enabled }))

**Wymagania:**
- `for_each` po `name` + walidacja unikalnosci.
- Walidacje zakresow (np. `frequency`, `timeout`, listy geo_locations niepuste).
- Outputs dla kluczy API jako `sensitive`.

---

### TASK-024-5: Diagnostic settings (inline, monitoring pattern)

**Cel:** Wbudowane `azurerm_monitor_diagnostic_setting` dla Application Insights.

**Do zrobienia:**
- `monitoring` input (lista obiektow) zgodnie z patternem po TASK-018.
- Brak data source `azurerm_monitor_diagnostic_categories` i brak mapowania `areas`.
- Uzytkownik podaje jawne `log_categories`/`metric_categories`.
- `diagnostic_settings_skipped` output jak w AKS/PGFS.

---

### TASK-024-6: Dokumentacja modulu

**Cel:** Kompletne docs zgodne z MODULE_GUIDE.

**Do zrobienia:**
- `README.md` z wymaganymi markerami i sekcjami (Module Documentation, Security Considerations).
- `docs/README.md`:
  - Overview, Managed Resources, Usage Notes
  - Out-of-scope zasoby (private endpoints, RBAC).
- `docs/IMPORT.md` wg AKS (import blocks + ID collection).
- `SECURITY.md`:
  - posture (public access, local auth, api keys)
  - secure example
  - checklist i typowe bledy
- `CONTRIBUTING.md` i `VERSIONING.md` zgodne z `module.json`.

---

### TASK-024-7: Examples (basic/complete/secure + feature-specific)

**Cel:** Przyklady zgodne z guide, uruchamialne lokalnie.

**Wymagane:**
- `examples/basic`: minimalny AI (classic lub workspace-based).
- `examples/complete`: retention + sampling + tags + diag settings.
- `examples/secure`: public ingestion/query disabled + local auth disabled.

**Feature-specific (propozycje):**
- `examples/api-keys`
- `examples/analytics-items`
- `examples/web-tests`
- `examples/standard-web-tests`
- `examples/workbooks`
- `examples/smart-detection-rules`

**Wymagania wspolne:**
- `source = "../.."`, stale nazwy, `README.md` + `.terraform-docs.yml`.
- Zasoby pomocnicze (RG, LAW) tworzone lokalnie w example.

---

### TASK-024-8: Testy (unit + integration + negative)

**Cel:** Zgodnosc z `docs/TESTING_GUIDE`.

**Unit tests (tftest.hcl):**
- walidacje nazw i zakresow (retention, sampling, daily cap).
- reguly permissions dla API keys.
- outputs z `try()`.

**Integration / Terratest:**
- fixtures: `basic`, `complete`, `secure`, `api-keys`, `analytics-items`,
  `web-tests`, `standard-web-tests`, `workbooks`, `smart-detection-rules`.
- weryfikacja:
  - properties AI (application_type, workspace_id, retention, sampling)
  - sub-resources (count + podstawowe pola)
  - diag settings (log/metric categories)

**Negatywne:**
- zly format nazwy
- invalid sampling/retention
- web test bez geo_locations

---

### TASK-024-9: Automatyzacja i release

**Cel:** Spojna automatyzacja i dokumentacja.

**Do zrobienia:**
- `tests/Makefile`, `test_env.sh`, `run_tests_*` jak w AKS.
- `generate-docs.sh` zgodny z guide.
- Aktualizacja `docs/_TASKS/README.md` po wdrozeniu.
- Wpis w `docs/_CHANGELOG/` dla nowego modulu.

---

## Acceptance Criteria

- Modul `modules/azurerm_application_insights` spelnia layout z MODULE_GUIDE.
- Pokrycie wszystkich funkcji z feature matrix + potwierdzonych w provider schema.
- README/SECURITY/IMPORT/CONTRIBUTING/VERSIONING kompletne i spojne.
- Examples basic/complete/secure + feature-specific gotowe i uruchamialne.
- Testy unit + integration + negative przechodza lokalnie.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md` (status + statystyki)
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-application-insights.md`
- `modules/README.md` (nowy modul w tabeli AzureRM)
- `README.md` (badges + tabela "Available Modules")
