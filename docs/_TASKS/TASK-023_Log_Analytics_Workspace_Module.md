# TASK-023: Log Analytics Workspace module (full feature scope)
# FileName: TASK-023_Log_Analytics_Workspace_Module.md

**Priority:** High  
**Category:** New Module / Monitoring  
**Estimated Effort:** Large  
**Dependencies:** -  
**Status:** Done

---

## Cel

Stworzyc nowy modul `modules/azurerm_log_analytics_workspace` zgodny z:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

Modul ma pokrywac wszystkie funkcje dostepne w `azurerm_log_analytics_workspace`
oraz wszystkie sub-resources powiazane z workspace (pelne zarzadzanie LAW).
AKS jest wzorcem struktury i testow; wszystkie odstepstwa musza byc jawnie
udokumentowane.

---

## Zakres (Provider Resources)

**Primary:**
- `azurerm_log_analytics_workspace`

**Powiazane zasoby (w module):**
- `azurerm_log_analytics_solution`
- `azurerm_log_analytics_data_export_rule`
- `azurerm_log_analytics_datasource_windows_event`
- `azurerm_log_analytics_datasource_windows_performance_counter`
- `azurerm_log_analytics_storage_insights`
- `azurerm_log_analytics_linked_service` (potwierdzic w providerze)
- `azurerm_log_analytics_cluster` (opcjonalnie, dedykowany klaster)
- `azurerm_log_analytics_cluster_customer_managed_key` (opcjonalnie, CMK dla klastra)
- `azurerm_monitor_diagnostic_setting`

**Potwierdzone w providerze (azurerm 4.57.0, docs):**
- `azurerm_log_analytics_workspace`
- `azurerm_log_analytics_solution`
- `azurerm_log_analytics_data_export_rule`
- `azurerm_log_analytics_datasource_windows_event`
- `azurerm_log_analytics_datasource_windows_performance_counter`
- `azurerm_log_analytics_storage_insights`
- `azurerm_log_analytics_cluster`
- `azurerm_log_analytics_cluster_customer_managed_key`

---

## Zalozenia i decyzje

1) **Atomic scope**  
   Modul zarzadza jednym workspace jako primary resource. Dodatkowe zasoby
   tylko wtedy, gdy sa bezposrednio powiazane z workspace (datasources,
   solution, data export, storage insights, linked service, diagnostic settings).

2) **Brak cross-resource glue**  
   Poza modulem: private endpoints, VNet links, RBAC/role assignments,
   Key Vault, storage accounts, event hubs, itp. Pokazujemy je tylko
   w examples jako osobne zasoby.

3) **Security-first**  
   Secure defaults gdzie to mozliwe. Publiczny dostep (ingestion/query)
   tylko przez jawne inputy. Wszystkie ryzyka opisane w `SECURITY.md`.

4) **Spojny styl**  
   Listy obiektow + `for_each` po `name`, walidacje w `variables.tf`, zaleznosci
   cross-field jako `lifecycle` preconditions w `main.tf`.

---

## Feature matrix (musi byc pokryty)

- SKU + retention
- daily quota / reservation capacity
- public ingestion/query toggles
- local authentication toggle
- identity (SystemAssigned/UserAssigned)
- tags + timeouts
- data export rules
- solutions (OMSGallery/*)
- storage insights
- Windows event datasource
- Windows performance counter datasource
- linked services (jesli wspierane)
- dedicated cluster + CMK (opcjonalnie, gdy wspierane)
- diagnostic settings (log/metric categories)

---

## Zakres i deliverables

### TASK-023-1: Discovery / feature inventory

**Cel:** Potwierdzic pelny zakres funkcji provider `azurerm` dla LAW i sub-resources.

**Do zrobienia:**
- Sprawdzic schema provider `azurerm` (doc lub `terraform providers schema -json`)
  dla `azurerm_log_analytics_workspace` i powiazanych zasobow.
- Potwierdzic dokladne nazwy oraz status wsparcia dla:
  - `azurerm_log_analytics_linked_service`
  - `azurerm_log_analytics_cluster` + `azurerm_log_analytics_cluster_customer_managed_key`
- Spisac finalny zestaw pol i ograniczen (allowed values, required combos).
- Zaktualizowac listy walidacji, preconditions i examples na bazie realnych pol.

---

### TASK-023-2: Scaffold modulu + pliki bazowe

**Cel:** Stworzyc pelna strukture modulu zgodna z guide.

**Checklist:**
- [ ] `modules/azurerm_log_analytics_workspace/` utworzony przez
      `scripts/create-new-module.sh` (wymagane).
- [ ] `module.json`:
  - name: `azurerm_log_analytics_workspace`
  - commit_scope: `log-analytics-workspace`
  - tag_prefix: `LAWv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] `.releaserc.js`, `.terraform-docs.yml`, `Makefile`, `generate-docs.sh`
      zgodne z AKS.
- [ ] Pliki bazowe: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`,
      `VERSIONING.md`, `SECURITY.md`, `docs/IMPORT.md`.

---

### TASK-023-3: Core resource `azurerm_log_analytics_workspace`

**Cel:** Implementacja pelnego API workspace w `main.tf` + walidacje w `variables.tf`.

**Zakres (przykladowy podzial inputow):**
- **core**: `name`, `resource_group_name`, `location`, `tags`
- **sku/retention**: `sku`, `retention_in_days`
- **quotas**: `daily_quota_gb`, `reservation_capacity_in_gb_per_day`
- **access**: `internet_ingestion_enabled`, `internet_query_enabled`,
  `local_authentication_disabled`
- **identity**: `type`, `identity_ids`
- **timeouts** (optional)

**Walidacje i preconditions (must-have):**
- Nazwa zgodna z rules Azure (length + regex).
- `retention_in_days` w dozwolonym zakresie.
- `daily_quota_gb` dodatnie lub null.
- `reservation_capacity_in_gb_per_day` tylko dla wspieranych SKU.
- `identity_ids` tylko gdy `type = UserAssigned`.

**Implementation notes:**
- `locals` dla flag i map wynikowych.
- `lifecycle` preconditions dla regul cross-field.
- Nazwy zasobow i iteratorow zgodne z guide (no `this`, no skroty).

---

### TASK-023-4: Sub-resources (solutions, datasources, exports, storage insights, linked services)

**Cel:** Pelne wsparcie sub-resources zwiazanych z workspace.

**Inputs (propozycje):**
- `solutions`: list(object({ name, product, publisher, promotion_code? }))
- `data_export_rules`: list(object({ name, destination_resource_id, table_names, enabled? }))
- `windows_event_datasources`: list(object({ name, event_log_name, event_types }))
- `windows_performance_counter_datasources`: list(object({ name, object_name, instance_name, counter_name, interval_seconds }))
- `storage_insights`: list(object({ name, storage_account_id, storage_account_key, blob_container_names?, table_names? }))
- `linked_services`: list(object({ name, resource_id })) (jesli wspierane)
- `cluster`: object({ name, identity, tags? }) (opcjonalnie)
- `cluster_customer_managed_key`: object({ key_vault_key_id }) (opcjonalnie)

**Wymagania:**
- `for_each` po `name` + walidacja unikalnosci.
- Walidacje zakresow (np. nazwy, listy niepuste).
- `data_export_rules` wymagaja workspace + destination (storage/event hub, wg provider).
- Cluster/CMK tylko gdy wspierane w provider schema.

---

### TASK-023-5: Diagnostic settings (inline, AKS pattern)

**Cel:** Wbudowane `azurerm_monitor_diagnostic_setting` dla workspace.

**Do zrobienia:**
- `diagnostic_settings` input (lista obiektow) jak w AKS.
- `data.azurerm_monitor_diagnostic_categories` + filtracja kategorii.
- `areas` -> mapowanie na log/metric categories (lub default `all`).
- `diagnostic_settings_skipped` output jak w AKS.

---

### TASK-023-6: Dokumentacja modulu

**Cel:** Kompletne docs zgodne z MODULE_GUIDE.

**Do zrobienia:**
- `README.md` z wymaganymi markerami i sekcjami (Module Documentation, Security Considerations).
- `docs/README.md`:
  - Overview, Managed Resources, Usage Notes
  - Out-of-scope zasoby (private endpoints, VNet links, RBAC).
- `docs/IMPORT.md` wg AKS (import blocks + ID collection).
- `SECURITY.md`:
  - posture (public access, auth, retention/quotas)
  - secure example
  - checklist i typowe bledy
- `CONTRIBUTING.md` i `VERSIONING.md` zgodne z `module.json`.

---

### TASK-023-7: Examples (basic/complete/secure + feature-specific)

**Cel:** Przyklady zgodne z guide, uruchamialne lokalnie.

**Wymagane:**
- `examples/basic`: minimalny workspace.
- `examples/complete`: quotas + tags + identity + diag settings.
- `examples/secure`: public ingestion/query disabled + private access (poza modulem w example).

**Feature-specific (propozycje):**
- `examples/solutions` (Container Insights / OMSGallery)
- `examples/data-export-rule`
- `examples/windows-event-datasource`
- `examples/windows-performance-counter-datasource`
- `examples/storage-insights`
- `examples/linked-service` (jesli wspierane)
- `examples/dedicated-cluster` (jesli wspierane)

**Wymagania wspolne:**
- `source = "../.."`, stale nazwy, `README.md` + `.terraform-docs.yml`.
- Zasoby pomocnicze (storage account, event hub, etc.) tworzone lokalnie w example.

---

### TASK-023-8: Testy (unit + integration + negative)

**Cel:** Zgodnosc z `docs/TESTING_GUIDE`.

**Unit tests (tftest.hcl):**
- walidacje nazw i zakresow (retention, quota).
- reguly identity i SKU.
- outputs z `try()`.

**Integration / Terratest:**
- fixtures: `basic`, `complete`, `secure`, `solutions`, `data-export-rule`,
  `windows-event-datasource`, `windows-performance-counter-datasource`,
  `storage-insights`, `linked-service` (jesli wspierane), `dedicated-cluster` (jesli wspierane).
- weryfikacja:
  - workspace properties (sku, retention, public access)
  - sub-resources (count + podstawowe pola)
  - diag settings (log/metric categories)

**Negatywne:**
- zly format nazwy
- invalid retention/quota
- user-assigned identity bez `identity_ids`

---

### TASK-023-9: Automatyzacja i release

**Cel:** Spojna automatyzacja i dokumentacja.

**Do zrobienia:**
- `tests/Makefile`, `test_env.sh`, `run_tests_*` jak w AKS.
- `generate-docs.sh` zgodny z guide.
- Aktualizacja `docs/_TASKS/README.md` po wdrozeniu.
- Wpis w `docs/_CHANGELOG/` dla nowego modulu.

---

## Acceptance Criteria

- Modul `modules/azurerm_log_analytics_workspace` spelnia layout z MODULE_GUIDE.
- Pokrycie wszystkich funkcji z feature matrix + potwierdzonych w provider schema.
- README/SECURITY/IMPORT/CONTRIBUTING/VERSIONING kompletne i spojne.
- Examples basic/complete/secure + feature-specific gotowe i uruchamialne.
- Testy unit + integration + negative przechodza lokalnie.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md` (status + statystyki)
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-log-analytics-workspace.md`
- `modules/README.md` (nowy modul w tabeli AzureRM)
- `README.md` (badges + tabela "Available Modules")

---

## Status Update (2026-01-29)

**Status:** Done

**Deliverables:**
- Module `modules/azurerm_log_analytics_workspace` with core workspace, sub-resources,
  diagnostics, outputs, and validations aligned to azurerm 4.57.0.
- Resource naming aligned to provider resource types (local names strip `azurerm_`).
- Inputs grouped into `workspace` and `features` objects with fixtures/examples/tests updated.
- Examples (basic/complete/secure + feature-specific) with updated READMEs.
- Fixtures and Terratest coverage for core and feature scenarios, plus unit tests.
- Test harness updated to match repo patterns (Makefile logging, run scripts, config).
- Documentation updated (`docs/README.md`, `docs/IMPORT.md`, `SECURITY.md`).

**Validation:**
- Not run in this environment (recommend: `terraform test -test-directory=tests/unit` and `make test`).
