# TASK-036: Azure Linux Function App module (full feature scope)
# FileName: TASK-036_Linux_Function_App_Module.md

**Priority:** High  
**Category:** New Module / App Service  
**Estimated Effort:** Large  
**Dependencies:** TASK-008 (Storage Account), TASK-024 (Application Insights), TASK-027 (User Assigned Identity) - optional for examples  
**Status:** Done

---

## Cel

Stworzyc nowy modul `modules/azurerm_linux_function_app` zgodny z:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

Modul ma pokrywac wszystkie funkcje dostepne dla
`azurerm_linux_function_app` oraz powiazane sub-resources App Service.
Windows Function App jest osobnym modulem (TASK-041).
AKS jest wzorcem struktury i testow; wszystkie odstepstwa musza byc jawnie
udokumentowane.

---

## Zakres (Provider Resources)

**Primary:**
- `azurerm_linux_function_app`

**Powiazane zasoby (w module):**
- `azurerm_linux_function_app_slot`
- `azurerm_monitor_diagnostic_setting`

**Wstepnie zidentyfikowane (azurerm 4.57.0, do potwierdzenia w TASK-036-1):**
- `azurerm_linux_function_app`
- `azurerm_linux_function_app_slot`

**Out-of-scope:**
- `azurerm_windows_function_app` (osobny modul, TASK-041)
- `azurerm_service_plan` / `azurerm_app_service_plan` (oddzielny modul)
- `azurerm_storage_account` (oddzielny modul)
- `azurerm_application_insights` (oddzielny modul)
- Private endpoints, Private DNS, VNet/DNS glue
- RBAC/role assignments, Key Vault, budgets, alerts
- Custom hostname bindings/certificates (App Service shared resources)

---

## Zalozenia i decyzje

1) **Atomic scope**  
   Modul zarzadza jednym Linux Function App jako primary resource. Dodatkowe
   zasoby tylko wtedy, gdy sa bezposrednio powiazane z Function App (slots,
   diagnostic settings).

2) **Brak cross-resource glue**  
   Poza modulem: service plan, storage account, Application Insights,
   private endpoints, Private DNS, RBAC, networking glue. Pokazujemy je tylko
   w examples jako osobne zasoby.

3) **Security-first**  
   Secure defaults gdzie to mozliwe (HTTPS-only, TLS >= 1.2, brak public access
   bez jawnego inputu). Ryzyka i wymagane konfiguracje opisane w `SECURITY.md`.

4) **Spojny styl**  
   Listy obiektow + `for_each` po `name`, walidacje w `variables.tf`,
   zaleznosci cross-field jako `lifecycle` preconditions w `main.tf`.

---

## Feature matrix (musi byc pokryty)

- Storage account (name + access key lub managed identity, wg schema)
- Runtime: `functions_extension_version` + `application_stack` (Linux)
- `app_settings` i `connection_strings`
- Deployment opcje (`zip_deploy_file`, `WEBSITE_RUN_FROM_PACKAGE`)
- `https_only`, `public_network_access_enabled`, `client_certificate_*`
- `site_config`:
  - TLS/FTPS/HTTP2
  - CORS
  - health check
  - ip restrictions + scm ip restrictions
  - always_on / prewarmed / elastic (Premium/Dedicated)
  - runtime-specific settings (dotnet/node/python/java/powershell)
- `auth_settings` / `auth_settings_v2`
- Identity (SystemAssigned/UserAssigned)
- Application Insights (connection string / key)
- Tags + timeouts
- Slots (app settings + site_config per slot)
- Diagnostic settings (log/metric categories)

---

## Zakres i deliverables

### TASK-036-1: Discovery / feature inventory

**Cel:** Potwierdzic pelny zakres funkcji provider `azurerm` dla Linux Function App i slotow.

**Do zrobienia:**
- Sprawdzic schema provider `azurerm` (doc lub `terraform providers schema -json`)
  dla:
  - `azurerm_linux_function_app`
  - `azurerm_linux_function_app_slot`
- Potwierdzic wymagane pola storage account oraz tryb managed identity
  (`storage_uses_managed_identity` i powiazane zaleznosci).
- Zweryfikowac wspierane bloki: `auth_settings` vs `auth_settings_v2`,
  `connection_string`, `site_config`, `ip_restriction`, `cors`, `health_check`.
- Spisac finalny zestaw pol i ograniczen (allowed values, required combos).

---

### TASK-036-2: Scaffold modulu + pliki bazowe

**Cel:** Stworzyc pelna strukture modulu zgodna z guide.

**Checklist:**
- [ ] `modules/azurerm_linux_function_app/` utworzony przez
      `scripts/create-new-module.sh` (wymagane).
- [ ] `module.json`:
  - name: `azurerm_linux_function_app`
  - commit_scope: `linux-function-app`
  - tag_prefix: `LFUNCv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] `.releaserc.js`, `.terraform-docs.yml`, `Makefile`, `generate-docs.sh`
      zgodne z AKS.
- [ ] Pliki bazowe: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`,
      `VERSIONING.md`, `SECURITY.md`, `docs/IMPORT.md`.

---

### TASK-036-3: Core resource (Linux Function App)

**Cel:** Implementacja pelnego API w `main.tf` + walidacje w `variables.tf`.

**Zakres (przykladowy podzial inputow):**
- **core**: `name`, `resource_group_name`, `location`, `tags`
- **platform**: `service_plan_id`, `functions_extension_version`
- **storage**: `storage_account_name`, `storage_account_access_key`,
  `storage_uses_managed_identity`
- **app settings**: `app_settings`, `connection_strings`
- **deployment**: `zip_deploy_file`, `builtin_logging_enabled`, `enabled`
- **access**: `https_only`, `public_network_access_enabled`,
  `client_certificate_enabled`, `client_certificate_mode`
- **monitoring**: `application_insights_connection_string`,
  `application_insights_key`
- **identity**: `type`, `identity_ids`
- **auth**: `auth_settings` / `auth_settings_v2`
- **site_config**: `always_on`, `ftps_state`, `http2_enabled`,
  `minimum_tls_version`, `scm_minimum_tls_version`, `cors`,
  `health_check_path`, `ip_restriction`, `scm_ip_restriction`,
  `vnet_route_all_enabled`, `application_stack` (Linux)
- **timeouts** (optional)

**Walidacje i preconditions (must-have):**
- `service_plan_id` wymagany.
- Storage:
  - klasyczny tryb: wymagany `storage_account_name` + `storage_account_access_key`
  - managed identity: wymagane `identity` + brak access key (zgodnie ze schema)
- `auth_settings` i `auth_settings_v2` wzajemnie wykluczajace.
- `application_stack`: tylko jeden runtime, wersje w dozwolonych wartosciach.
- `minimum_tls_version` i `scm_minimum_tls_version` w dozwolonych wartosciach.
- `client_certificate_mode` tylko gdy `client_certificate_enabled = true`.
- Warunkowe walidacje `always_on` / `prewarmed` / `elastic` wg typu planu
  (do potwierdzenia w TASK-036-1).

**Implementation notes:**
- `locals` dla flag i map wynikowych.
- `lifecycle` preconditions dla regul cross-field.
- Nazwy zasobow i iteratorow zgodne z guide (no `this`, no skroty).

---

### TASK-036-4: Slots (Linux)

**Cel:** Pelne wsparcie slotow Linux Function App.

**Inputs (propozycja):**
- `slots`: list(object({
    name
    app_settings?
    connection_strings?
    site_config?
    auth_settings?
    auth_settings_v2?
    identity?
    enabled?
    https_only?
  }))

**Wymagania:**
- `for_each` po `name` + walidacja unikalnosci.
- `auth_settings` vs `auth_settings_v2` wzajemnie wykluczajace na slotach.
- Walidacje runtime i site_config zgodne z primary.

---

### TASK-036-5: Diagnostic settings (inline, AKS pattern)

**Cel:** Wbudowane `azurerm_monitor_diagnostic_setting` dla Linux Function App.

**Do zrobienia:**
- `diagnostic_settings` input (lista obiektow) jak w AKS.
- `data.azurerm_monitor_diagnostic_categories` + filtracja kategorii.
- `areas` -> mapowanie na log/metric categories (lub default `all`).
- `diagnostic_settings_skipped` output jak w AKS/PGFS.

---

### TASK-036-6: Dokumentacja modulu

**Cel:** Kompletne docs zgodne z MODULE_GUIDE.

**Do zrobienia:**
- `README.md` z wymaganymi markerami i sekcjami (Module Documentation, Security Considerations).
- `docs/README.md`:
  - Overview, Managed Resources, Usage Notes
  - Out-of-scope zasoby (service plan, storage account, App Insights, private endpoints).
- `docs/IMPORT.md` wg AKS (import blocks + ID collection).
- `SECURITY.md`:
  - posture (public access, auth, TLS, app settings)
  - secure example + checklist
- `CONTRIBUTING.md` i `VERSIONING.md` zgodne z `module.json`.

---

### TASK-036-7: Examples (basic/complete/secure + feature-specific)

**Cel:** Przyklady zgodne z guide, uruchamialne lokalnie.

**Wymagane:**
- `examples/basic`: minimalna konfiguracja Linux.
- `examples/complete`: `site_config` + auth + app settings + diag settings.
- `examples/secure`: `public_network_access_enabled = false`, TLS 1.2, IP restrictions,
  wlasna identity + App Insights (jesli uzywane).

**Feature-specific (propozycje):**
- `examples/slots`
- `examples/app-settings-and-conn-strings`
- `examples/auth-settings-v2`
- `examples/zip-deploy`
- `examples/linux-container` (jesli wspierane)

**Wymagania wspolne:**
- `source = "../.."`, stale nazwy, `README.md` + `.terraform-docs.yml`.
- Zasoby pomocnicze (RG, storage, service plan, App Insights) tworzone lokalnie
  w example jako osobne zasoby lub przez istniejace moduly.

---

### TASK-036-8: Testy (unit + integration + negative)

**Cel:** Zgodnosc z `docs/TESTING_GUIDE`.

**Unit tests (tftest.hcl):**
- storage account rules (classic vs managed identity).
- `auth_settings` vs `auth_settings_v2`.
- `application_stack` (dokladnie jeden runtime, poprawne wersje).
- `client_certificate_*` oraz TLS/minimum.

**Integration / Terratest:**
- fixtures: `basic`, `complete`, `secure`, `slots`, `auth-settings-v2`.
- weryfikacja:
  - status app (https_only, public access, identity)
  - ustawienia `site_config` i `app_settings`
  - sloty i ich app settings
  - diag settings (log/metric categories)

**Negatywne:**
- brak `service_plan_id`
- brak storage account w trybie klasycznym
- `auth_settings` i `auth_settings_v2` jednoczesnie
- `application_stack` z wieloma runtime

---

### TASK-036-9: Automatyzacja i release

**Cel:** Spojna automatyzacja i dokumentacja.

**Do zrobienia:**
- `tests/Makefile`, `test_env.sh`, `run_tests_*` jak w AKS.
- `generate-docs.sh` zgodny z guide.
- Aktualizacja `docs/_TASKS/README.md` po wdrozeniu.
- Wpis w `docs/_CHANGELOG/` dla nowego modulu.

---

## Acceptance Criteria

- Modul `modules/azurerm_linux_function_app` spelnia layout z MODULE_GUIDE.
- Pokrycie wszystkich funkcji z feature matrix + potwierdzonych w provider schema.
- README/SECURITY/IMPORT/CONTRIBUTING/VERSIONING kompletne i spojne.
- Examples basic/complete/secure + feature-specific gotowe i uruchamialne.
- Testy unit + integration + negative przechodza lokalnie.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md` (status + statystyki)
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-linux-function-app.md`
- `modules/README.md` (nowy modul w tabeli AzureRM)
- `README.md` (badges + tabela "Available Modules")
