# TASK-053: Azure App Service Plan module (full feature scope)
# FileName: TASK-053_Azure_App_Service_Plan_Module.md

**Priority:** High  
**Category:** New Module / App Service  
**Estimated Effort:** Large  
**Dependencies:** TASK-023 (Log Analytics Workspace) - optional for diagnostics examples  
**Status:** Done

---

## Cel

Stworzyc nowy modul `modules/azurerm_service_plan` zgodny z:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

Modul ma pokrywac pelny zakres `azurerm_service_plan` z AzureRM 4.57.0 oraz
repo-we wymagania dla layoutu, docs, examples, unit testow, Terratest i
Makefile. Struktura testow, fixtures i konfiguracji `*.go` ma byc blizniacza
do `modules/azurerm_postgresql_flexible_server`.

---

## Zakres (Provider Resources)

**Primary:**
- `azurerm_service_plan`

**Powiazane zasoby (w module):**
- `azurerm_monitor_diagnostic_setting`

**Out-of-scope:**
- Web Apps / Function Apps / Logic Apps uruchamiane na planie
- App Service Environment creation (`azurerm_app_service_environment_v3`)
- Private endpoints, Private DNS, VNet glue
- RBAC/role assignments, budgets, alerts
- Log Analytics Workspace / Storage Account / Event Hub jako destynacje diagnostyk

---

## Zalozenia i decyzje

1) **Atomic scope**  
   Modul zarzadza pojedynczym App Service Plan jako primary resource oraz
   inline diagnostic settings.

2) **Brak cross-resource glue**  
   Modul nie tworzy aplikacji hostowanych na planie ani zasobow pomocniczych
   poza diagnostic settings.

3) **Security-first**  
   W samym planie nacisk pada na izolacje (ASE), placement (zone balancing),
   przewidywalne skalowanie i centralna diagnostyke. App-level security zostaje
   w osobnych modulach.

4) **PGFS-style test harness parity**  
   `Makefile`, `tests/Makefile`, Terratest layout, fixtures, `test_config.yaml`,
   `run_tests_parallel.sh`, `run_tests_sequential.sh`, `test_helpers.go` i
   unit tests utrzymane w tym samym stylu co
   `modules/azurerm_postgresql_flexible_server`.

---

## Feature matrix (pokryte)

- `os_type`: `Windows`, `Linux`, `WindowsContainer`
- SKU validation wg AzureRM 4.57.0
- `app_service_environment_id` dla isolated v2 / ASE v3
- `premium_plan_auto_scale_enabled`
- `maximum_elastic_worker_count`
- `worker_count`
- `per_site_scaling_enabled`
- `zone_balancing_enabled`
- `tags`
- `timeouts`
- Inline diagnostic settings:
  - `AppServiceConsoleLogs`
  - `AppServicePlatformLogs`
  - `AllMetrics`

---

## Deliverables

### TASK-053-1: Discovery / provider scope

**Done**
- Potwierdzono zakres `azurerm_service_plan` wg oficjalnej dokumentacji provider
  i ograniczenia SKU / ASE / zone balancing / Elastic Premium.

### TASK-053-2: Scaffold modulu + pliki bazowe

**Done**
- Utworzono `modules/azurerm_service_plan/`
- Dodano:
  - `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`
  - `README.md`, `CHANGELOG.md`, `VERSIONING.md`, `CONTRIBUTING.md`, `SECURITY.md`
  - `module.json`, `.releaserc.js`, `.terraform-docs.yml`, `Makefile`, `generate-docs.sh`
  - `docs/README.md`, `docs/IMPORT.md`

### TASK-053-3: Core resource implementation

**Done**
- Zaimplementowano `azurerm_service_plan`
- Dodano structured input `service_plan`
- Dodano walidacje cross-field dla:
  - supported `os_type`
  - supported `sku_name`
  - ASE + isolated SKU
  - Elastic Premium / Premium autoscale rules
  - zone balancing + `worker_count`

### TASK-053-4: Diagnostic settings

**Done**
- Dodano inline `azurerm_monitor_diagnostic_setting`
- Dodano explicit allow-lists dla supported categories
- Dodano `diagnostic_settings_skipped`

### TASK-053-5: Examples i docs

**Done**
- Wymagane examples:
  - `examples/basic`
  - `examples/complete`
  - `examples/secure`
- Feature-specific example:
  - `examples/elastic-premium`
- Uzupełniono README/docs/import/security/versioning/contributing

### TASK-053-6: Testy

**Done**
- Unit tests:
  - `defaults.tftest.hcl`
  - `diagnostic_settings.tftest.hcl`
  - `naming.tftest.hcl`
  - `outputs.tftest.hcl`
  - `validation.tftest.hcl`
- Terratest fixtures:
  - `basic`
  - `complete`
  - `secure`
  - `elastic`
  - `negative`
- Go tests:
  - `service_plan_test.go`
  - `integration_test.go`
  - `performance_test.go`
  - `test_helpers.go`
- `Makefile` i `tests/Makefile` utrzymane w blizniaczym patternie do PGFS

### TASK-053-7: Repo docs / task board updates

**Done**
- Dodano ten task file
- Zaktualizowano `docs/_TASKS/README.md`
- Zaktualizowano repo indexes (`README.md`, `modules/README.md`) dla nowego modulu

---

## Rezultat

Nowy modul `modules/azurerm_service_plan` jest gotowy jako atomic module dla
Azure App Service Plans i spelnia repo-we wymagania dotyczace struktury,
dokumentacji oraz PGFS-style test harness parity.
