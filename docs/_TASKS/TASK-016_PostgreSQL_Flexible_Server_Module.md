# TASK-016: PostgreSQL Flexible Server module (full feature scope)
# FileName: TASK-016_PostgreSQL_Flexible_Server_Module.md

**Priority:** High  
**Category:** New Module / Database  
**Estimated Effort:** Large  
**Dependencies:** -  
**Status:** To Do

---

## Cel

Stworzyc nowy modul `modules/azurerm_postgresql_flexible_server` zgodny z:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

Modul ma pokrywac wszystkie funkcje dostepne w `azurerm_postgresql_flexible_server`
oraz powiazane sub-resources serwerowe (wersja zgodna z `versions.tf`).
AKS jest wzorcem struktury i testow; wszystkie odstepstwa musza byc jawnie
udokumentowane.

---

## Zakres (Provider Resources)

**Primary:**
- `azurerm_postgresql_flexible_server`

**Powiazane zasoby (w module):**
- `azurerm_postgresql_flexible_server_configuration`
- `azurerm_postgresql_flexible_server_firewall_rule`
- `azurerm_postgresql_flexible_server_active_directory_administrator`
- `azurerm_postgresql_flexible_server_virtual_endpoint`
- `azurerm_postgresql_flexible_server_backup_threat_detection_policy` (nazwa do potwierdzenia)
- `azurerm_monitor_diagnostic_setting`

**Potwierdzone w providerze (azurerm 4.57.0, scan binarki):**
- `azurerm_postgresql_flexible_server`
- `azurerm_postgresql_flexible_server_active_directory_administrator`
- `azurerm_postgresql_flexible_server_configuration`
- `azurerm_postgresql_flexible_server_firewall_rule`
- `azurerm_postgresql_flexible_server_database` (out-of-scope, osobny modul)
- `azurerm_postgresql_flexible_server_virtual_endpoint`
- `azurerm_postgresql_flexible_server_backup_threat_detection_policy` (nazwa do potwierdzenia; binarka wskazuje `backupthreat`)

---

## Zalozenia i decyzje

1) **Atomic scope**  
   Modul zarzadza jednym serwerem jako primary resource. Dodatkowe zasoby tylko
   wtedy, gdy sa zwiazane z serwerem: konfiguracje, firewall, AAD admin,
   virtual endpoint, backup threat detection policy, diagnostic settings.
   Bazy sa osobnym modulem.

2) **Brak cross-resource glue**  
   Poza modulem: private endpoints, VNet links, RBAC/role assignments, Key Vault,
   Private DNS Zone, monitoring workspace, backup vault itd. Pokazujemy je tylko
   w examples jako osobne zasoby.

3) **Security-first**  
   Secure defaults gdzie to mozliwe. Publiczny dostep tylko przez jawne inputy.
   Wszystkie ryzyka opisane w `SECURITY.md`.

4) **Spojny styl**  
   Listy obiektow + `for_each` po `name`, walidacje w `variables.tf`, zaleznosci
   cross-field jako `lifecycle` preconditions w `main.tf`.

---

## Feature matrix (musi byc pokryty)

- Compute/Version/SKU (tier/size)
- Storage (size, tier, auto-grow/iops jesli wspierane)
- Backup (retention, geo-redundant backup)
- Backup threat detection policy (jesli wspierane)
- High availability (mode + standby zone)
- Maintenance window
- Network (public access toggle, delegated subnet, private DNS zone)
- Authentication (password + AAD)
- Admin credentials
- Identity (SystemAssigned/UserAssigned)
- Customer managed keys (primary + geo backup)
- Create modes (Default / PointInTimeRestore / GeoRestore / Replica)
- Configurations, firewall rules, AAD admin
- Virtual endpoint (replica routing / read-only, jesli wspierane)
- Diagnostic settings (log/metric categories, filters)
- Tags i timeouts

---

## Zakres i deliverables

### TASK-016-1: Discovery / feature inventory

**Cel:** Potwierdzic pelny zakres funkcji provider `azurerm` dla PG flexible.

**Do zrobienia:**
- Sprawdzic schema provider `azurerm` (doc lub `terraform providers schema -json`)
  dla `azurerm_postgresql_flexible_server` i sub-resources serwerowych.
- Potwierdzic dokladne nazwy oraz status wsparcia dla:
  - `azurerm_postgresql_flexible_server_virtual_endpoint`
  - `azurerm_postgresql_flexible_server_backup_threat_detection_policy`
- Potwierdzic, ze oba resource'y sa server-scope (nie database-scope).
- Spisac finalny zestaw pol i ograniczen (allowed values, required combos).
- Zaktualizowac listy walidacji, preconditions i examples na bazie realnych pol.

---

### TASK-016-2: Scaffold modulu + pliki bazowe

**Cel:** Stworzyc pelna strukture modulu zgodna z guide.

**Checklist:**
- [ ] `modules/azurerm_postgresql_flexible_server/` utworzony przez
      `scripts/create-new-module.sh` (wymagane).
- [ ] `module.json`:
  - name: `azurerm_postgresql_flexible_server`
  - commit_scope: `postgresql-flexible-server`
  - tag_prefix: `PGFSv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] `.releaserc.js`, `.terraform-docs.yml`, `Makefile`, `generate-docs.sh`
      zgodne z AKS.
- [ ] Pliki bazowe: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`,
      `VERSIONING.md`, `SECURITY.md`, `docs/IMPORT.md`.

---

### TASK-016-3: Core resource `azurerm_postgresql_flexible_server`

**Cel:** Implementacja pelnego API serwera w `main.tf` + walidacje w `variables.tf`.

**Zakres (przykladowy podzial inputow):**
- **core**: `name`, `resource_group_name`, `location`, `tags`
- **version + sku**: `version`, `sku_name`
- **admin**: `administrator_login`, `administrator_password`
- **storage**: `storage_mb`, `storage_tier`, `auto_grow_enabled`, `iops` (jesli wspierane)
- **backup**: `backup_retention_days`, `geo_redundant_backup_enabled`
- **network**: `public_network_access_enabled`, `delegated_subnet_id`, `private_dns_zone_id`
- **auth**: `authentication` (password/AAD + tenant_id)
- **high_availability**: `mode`, `standby_availability_zone`
- **maintenance_window**: `day_of_week`, `start_hour`, `start_minute`
- **identity**: `type`, `identity_ids`
- **customer_managed_key**: `key_vault_key_id`, `primary_user_assigned_identity_id`,
  `geo_backup_key_vault_key_id`, `geo_backup_user_assigned_identity_id`
- **create_mode**: `mode`, `source_server_id`, `point_in_time_restore_time_in_utc`
- **timeouts** (optional)

**Walidacje i preconditions (must-have):**
- Nazwa serwera zgodna z rules Azure (length + regex).
- `version` w dozwolonym zbiorze.
- `backup_retention_days` w zakresie (np. 7-35).
- `maintenance_window` (day/hour/minute) w dozwolonych zakresach.
- `authentication`:
  - AD auth -> wymagany `tenant_id` i AAD admin.
  - password auth -> wymagany `administrator_password`.
- `public_network_access_enabled = false` -> wymagany `delegated_subnet_id`
  i `private_dns_zone_id`.
- `firewall_rules` tylko gdy public access jest wlaczony.
- `create_mode`:
  - `Replica` i `PointInTimeRestore` wymagaja `source_server_id`.
  - `PointInTimeRestore` wymaga `point_in_time_restore_time_in_utc`.
  - `Default` nie moze miec restore/replica inputs.
- `high_availability`:
  - `mode` w dozwolonych wartosciach.
  - `standby_availability_zone` tylko gdy tryb HA to `ZoneRedundant`.
- `customer_managed_key` wymaga `identity` z user-assigned.

**Implementation notes:**
- `locals` dla flag i map wynikowych.
- `lifecycle` preconditions dla regul cross-field.
- Nazwy zasobow i iteratorow zgodne z guide (no `this`, no skroty).

---

### TASK-016-4: Sub-resources (configurations, firewall, AAD admin, virtual endpoint, backup threat detection)

**Cel:** Pelne wsparcie sub-resources zwiazanych z serwerem.

**Inputs:**
- `configurations`: list(object({ name, value, source? }))
- `firewall_rules`: list(object({ name, start_ip_address, end_ip_address }))
- `active_directory_administrator`: object({
    principal_name, object_id, principal_type, tenant_id
  }) lub list (jesli provider wspiera)
- `virtual_endpoints`: object lub list (zgodnie z provider schema)
- `backup_threat_detection_policy`: object (zgodnie z provider schema)

**Wymagania:**
- `for_each` po `name` + walidacja unikalnosci.
- Walidacje zakresow (np. IP, nazw DB).
- AAD admin tylko gdy `authentication.active_directory_auth_enabled = true`.
- Walidacje i preconditions dla virtual endpoint / threat detection zgodnie z schema.

---

### TASK-016-5: Diagnostic settings (inline, AKS pattern)

**Cel:** Wbudowane `azurerm_monitor_diagnostic_setting` dla serwera.

**Do zrobienia:**
- `diagnostic_settings` input (lista obiektow) jak w AKS.
- `data.azurerm_monitor_diagnostic_categories` + filtracja kategorii.
- `areas` -> mapowanie na log/metric categories (lub default `all`).
- `diagnostic_settings_skipped` output jak w AKS.

---

### TASK-016-6: Dokumentacja modulu

**Cel:** Kompletne docs zgodne z MODULE_GUIDE.

**Do zrobienia:**
- `README.md` z wymaganymi markerami i sekcjami (Module Documentation, Security Considerations).
- `docs/README.md`:
  - Overview, Managed Resources, Usage Notes
  - Out-of-scope zasoby (private endpoints, VNet links, RBAC).
- `docs/IMPORT.md` wg AKS (import blocks + ID collection).
- `SECURITY.md`:
  - posture (private network, auth, CMK, backup)
  - secure example
  - checklist i typowe bledy
- `CONTRIBUTING.md` i `VERSIONING.md` zgodne z `module.json`.

---

### TASK-016-7: Examples (basic/complete/secure + feature-specific)

**Cel:** Przyklady zgodne z guide, uruchamialne lokalnie.

**Wymagane:**
- `examples/basic`: public access, minimal config.
- `examples/complete`: HA + maintenance window + configs + diag settings.
- `examples/secure`: private access + AAD auth + CMK (jesli wspierane) + brak public.

**Feature-specific (propozycje):**
- `examples/diagnostic-settings`
- `examples/replica`
- `examples/point-in-time-restore`
- `examples/configurations`
- `examples/firewall-rules` (public)
- `examples/aad-auth`
- `examples/customer-managed-key`
- `examples/virtual-endpoint`
- `examples/backup-threat-detection-policy`

**Wymagania wspolne:**
- `source = "../.."`, stale nazwy, `README.md` + `.terraform-docs.yml`.
- Zasoby pomocnicze (VNet, subnet, private DNS) tworzone lokalnie w example.

---

### TASK-016-8: Testy (unit + integration + negative)

**Cel:** Zgodnosc z `docs/TESTING_GUIDE`.

**Unit tests (tftest.hcl):**
- walidacje nazw i zakresow (version, backup retention, storage).
- zasady `create_mode` (default/restore/replica).
- reguly `authentication` i AAD admin.
- reguly network (public vs private + firewall).
- outputs z `try()`.

**Integration / Terratest:**
- fixtures: `basic`, `complete`, `secure`, `aad-auth`, `configurations`,
  `diagnostic-settings`, `replica`, `point-in-time-restore`,
  `virtual-endpoint`, `backup-threat-detection-policy`.
- weryfikacja:
  - stan serwera (HA, backup, network, version)
  - configs + firewall rules
  - AAD admin (jesli enabled)
  - diag settings (log/metric categories)
- public fixtures: utworzyc `azurerm_postgresql_flexible_server_database`
  jako zasob pomocniczy do walidacji polaczenia (poza modulem). Jesli
  wykonalne, wykonac proste `SELECT 1` (psql/pgx). Dla private scenariuszy
  pominac testy polaczenia (brak VPN/huba).
- scenariusze restore/replica uruchamiane sekwencyjnie.

**Negatywne:**
- brak `source_server_id` dla restore/replica
- public access disabled bez subnet/dns
- AAD auth bez AAD admin/tenant_id

---

### TASK-016-9: Automatyzacja i release

**Cel:** Spojna automatyzacja i dokumentacja.

**Do zrobienia:**
- `tests/Makefile`, `test_env.sh`, `run_tests_*` jak w AKS.
- `generate-docs.sh` zgodny z guide.
- Aktualizacja `docs/_TASKS/README.md` po wdrozeniu.
- Wpis w `docs/_CHANGELOG/` dla nowego modulu.

---

## Acceptance Criteria

- Modul `modules/azurerm_postgresql_flexible_server` spelnia layout z MODULE_GUIDE.
- Pokrycie wszystkich funkcji z feature matrix + potwierdzonych w provider schema.
- README/SECURITY/IMPORT/CONTRIBUTING/VERSIONING kompletne i spojne.
- Examples basic/complete/secure + feature-specific gotowe i uruchamialne.
- Testy unit + integration + negative przechodza lokalnie.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md` (status + statystyki)
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-postgresql-flexible-server.md`
- `modules/README.md` (nowy modul w tabeli AzureRM)
- `README.md` (badges + tabela "Available Modules")
