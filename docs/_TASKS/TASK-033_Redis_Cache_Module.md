# TASK-033: Azure Redis Cache module (full feature scope)
# FileName: TASK-033_Redis_Cache_Module.md

**Priority:** High  
**Category:** New Module / Cache  
**Estimated Effort:** Medium  
**Dependencies:** -  
**Status:** Planned

---

## Cel

Stworzyc nowy modul `modules/azurerm_redis_cache` zgodny z:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

Modul ma pokrywac wszystkie funkcje dostepne w `azurerm_redis_cache`
oraz powiazane sub-resources Redis. AKS jest wzorcem struktury i testow;
wszystkie odstepstwa musza byc jawnie udokumentowane.

---

## Zakres (Provider Resources)

**Primary:**
- `azurerm_redis_cache`

**Powiazane zasoby (w module):**
- `azurerm_redis_firewall_rule`
- `azurerm_redis_patch_schedule`
- `azurerm_redis_linked_server`
- `azurerm_monitor_diagnostic_setting`

**Potwierdzone w providerze (azurerm 4.57.0, do potwierdzenia w TASK-033-1):**
- `azurerm_redis_cache`
- `azurerm_redis_firewall_rule`
- `azurerm_redis_patch_schedule`
- `azurerm_redis_linked_server`

**Out-of-scope:**
- Redis Enterprise (`azurerm_redis_enterprise_cluster`, `azurerm_redis_enterprise_database`)
- Private endpoints, Private DNS, VNet/DNS glue
- RBAC/role assignments, identity provisioning
- Monitoring workspace, alerts, dashboards

---

## Zalozenia i decyzje

1) **Atomic scope**  
   Modul zarzadza jednym Redis Cache jako primary resource. Dodatkowe zasoby
   tylko wtedy, gdy sa bezposrednio powiazane z Redis (firewall, patch schedule,
   linked server, diagnostic settings).

2) **Brak cross-resource glue**  
   Poza modulem: private endpoints, Private DNS, RBAC, networking glue,
   Log Analytics workspace. Pokazujemy je tylko w examples jako osobne zasoby.

3) **Security-first**  
   Secure defaults gdzie to mozliwe: TLS >= 1.2, brak non-SSL port, public access
   tylko przez jawny input. Ryzyka opisane w `SECURITY.md`.

4) **Spojny styl**  
   Listy obiektow + `for_each` po `name`, walidacje w `variables.tf`,
   zaleznosci cross-field jako `lifecycle` preconditions w `main.tf`.

---

## Feature matrix (musi byc pokryty)

- SKU/family/capacity + valid combos
- Zones (jesli wspierane)
- Redis version (jesli wspierane)
- TLS + non-SSL port
- Network: public access toggle, VNet injection (`subnet_id`, `private_static_ip_address`)
- Clustering/replicas (`shard_count`, `replicas_per_master` lub odpowiednik)
- `redis_configuration` (persistence, memory, keyspace notifications, itp.)
- Patch schedule (premium)
- Firewall rules (tylko gdy public access)
- Linked server / geo-replication (premium)
- Tags + timeouts
- Diagnostic settings (log/metric categories)

---

## Zakres i deliverables

### TASK-033-1: Discovery / feature inventory

**Cel:** Potwierdzic pelny zakres funkcji provider `azurerm` dla Redis Cache i sub-resources.

**Do zrobienia:**
- Sprawdzic schema provider `azurerm` (doc lub `terraform providers schema -json`)
  dla:
  - `azurerm_redis_cache`
  - `azurerm_redis_firewall_rule`
  - `azurerm_redis_patch_schedule`
  - `azurerm_redis_linked_server`
- Potwierdzic dokladne nazwy pol i dozwolone wartosci (sku/family/capacity,
  `minimum_tls_version`, `public_network_access_enabled`, `zones`, `redis_version`).
- Zweryfikowac ograniczenia Premium:
  - VNet injection (`subnet_id`, `private_static_ip_address`)
  - clustering (`shard_count`, `replicas_per_master`)
  - patch schedule
  - linked server
- Spisac finalny zestaw pol `redis_configuration` i zaleznosci miedzy nimi
  (backup enable + connection stringi).

---

### TASK-033-2: Scaffold modulu + pliki bazowe

**Cel:** Stworzyc pelna strukture modulu zgodna z guide.

**Checklist:**
- [ ] `modules/azurerm_redis_cache/` utworzony przez
      `scripts/create-new-module.sh` (wymagane).
- [ ] `module.json`:
  - name: `azurerm_redis_cache`
  - commit_scope: `redis-cache`
  - tag_prefix: `REDISv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] `.releaserc.js`, `.terraform-docs.yml`, `Makefile`, `generate-docs.sh`
      zgodne z AKS.
- [ ] Pliki bazowe: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`,
      `VERSIONING.md`, `SECURITY.md`, `docs/IMPORT.md`.

---

### TASK-033-3: Core resource `azurerm_redis_cache`

**Cel:** Implementacja pelnego API Redis Cache w `main.tf` + walidacje w `variables.tf`.

**Zakres (propozycja inputow):**
- **core**: `name`, `resource_group_name`, `location`, `tags`
- **sku**: `sku_name`, `family`, `capacity`
- **network**: `public_network_access_enabled`, `subnet_id`, `private_static_ip_address`
- **security**: `minimum_tls_version`, `enable_non_ssl_port`
- **availability**: `zones`
- **scale**: `shard_count`, `replicas_per_master` (lub wg schema)
- **redis_configuration**: object (persistence, memory, notifications, itp.)
- **timeouts** (optional)

**Walidacje i preconditions (must-have):**
- Nazwa zgodna z rules Azure (length + regex).
- `sku_name`, `family`, `capacity` w dozwolonych kombinacjach.
- `minimum_tls_version` w dozwolonym zbiorze.
- `subnet_id` tylko dla Premium; gdy ustawione, wymagany `private_static_ip_address`
  i `public_network_access_enabled = false` (wg schema).
- `shard_count` i `replicas_per_master` tylko dla Premium.
- `redis_configuration`:
  - backup enable -> wymagane connection stringi
  - wartosci liczbowe w zakresie (wg schema)

**Implementation notes:**
- `locals` dla flag i map wynikowych.
- `lifecycle` preconditions dla regul cross-field.
- Nazwy zasobow i iteratorow zgodne z guide (no `this`, no skroty).

---

### TASK-033-4: Sub-resources (firewall, patch schedule, linked server)

**Cel:** Pelne wsparcie sub-resources zwiazanych z Redis Cache.

**Inputs (propozycje):**
- `firewall_rules`: list(object({ name, start_ip_address, end_ip_address }))
- `patch_schedule`: list(object({ day_of_week, start_hour_utc })) lub
  object zgodny z schema `azurerm_redis_patch_schedule`
- `linked_servers`: list(object({
    name, linked_redis_cache_id, linked_redis_cache_location, server_role
  }))

**Wymagania:**
- `for_each` po `name` + walidacja unikalnosci.
- `firewall_rules` tylko gdy `public_network_access_enabled = true`.
- `patch_schedule` tylko dla Premium.
- `linked_servers` tylko dla Premium; walidacje `server_role` wg schema.

---

### TASK-033-5: Diagnostic settings (inline, AKS pattern)

**Cel:** Wbudowane `azurerm_monitor_diagnostic_setting` dla Redis Cache.

**Do zrobienia:**
- `diagnostic_settings` input (lista obiektow) jak w AKS.
- `data.azurerm_monitor_diagnostic_categories` + filtracja kategorii.
- `diagnostic_settings_skipped` output jak w AKS.

---

### TASK-033-6: Dokumentacja modulu

**Cel:** Kompletne docs zgodne z MODULE_GUIDE.

**Do zrobienia:**
- `README.md` z wymaganymi markerami i sekcjami (Module Documentation, Security Considerations).
- `docs/README.md`:
  - Overview, Managed Resources, Usage Notes
  - Out-of-scope zasoby (private endpoints, RBAC, networking glue).
- `docs/IMPORT.md` wg AKS (import blocks + ID collection).
- `SECURITY.md`:
  - public access vs firewall rules
  - non-SSL port i TLS minimum
  - persistence connection strings w state
- `CONTRIBUTING.md` i `VERSIONING.md` zgodne z `module.json`.

---

### TASK-033-7: Examples (basic/complete/secure + feature-specific)

**Wymagane:**
- `examples/basic`: standard sku, public access, minimal config.
- `examples/complete`: premium + clustering + patch schedule + firewall rules
  + diagnostic settings + redis_configuration.
- `examples/secure`: VNet injection + brak public access + TLS >= 1.2.

**Feature-specific (propozycje):**
- `examples/diagnostic-settings`
- `examples/patch-schedule`
- `examples/linked-server`
- `examples/firewall-rules`
- `examples/vnet-injection`
- `examples/redis-configuration`

**Wymagania wspolne:**
- `source = "../.."`, stale nazwy, `README.md` + `.terraform-docs.yml`.
- Zasoby pomocnicze (RG, VNet, subnet, storage) tworzone lokalnie w example.

---

### TASK-033-8: Testy (unit + integration + negative)

**Unit tests (tftest.hcl):**
- walidacje nazwy.
- `sku_name`/`family`/`capacity` combos.
- `subnet_id` tylko dla Premium.
- `firewall_rules` tylko gdy public access enabled.
- `patch_schedule` tylko dla Premium.
- `linked_servers` tylko dla Premium.
- `redis_configuration` zaleznosci (backup -> connection stringi).
- outputs z `try()`.

**Integration / Terratest:**
- fixtures: `basic`, `secure`, `patch-schedule`, `linked-server`, `firewall-rules`.
- opcjonalnie: prosty test data-plane (PING/SET/GET) w public fixture.
- private fixtures bez testu polaczenia (brak VPN/huba).

**Negatywne:**
- `patch_schedule` bez Premium.
- `firewall_rules` przy public access disabled.
- `subnet_id` dla non-Premium.
- backup enabled bez connection stringow.

---

### TASK-033-9: Automatyzacja i release

**Cel:** Spojna automatyzacja i dokumentacja.

**Do zrobienia:**
- `tests/Makefile`, `test_env.sh`, `run_tests_*` jak w AKS.
- `generate-docs.sh` zgodny z guide.
- Aktualizacja `docs/_TASKS/README.md` po wdrozeniu.
- Wpis w `docs/_CHANGELOG/` dla nowego modulu.

---

## Acceptance Criteria

- Modul `modules/azurerm_redis_cache` spelnia layout z MODULE_GUIDE.
- Pokrycie wszystkich funkcji z feature matrix + potwierdzonych w provider schema.
- README/SECURITY/IMPORT/CONTRIBUTING/VERSIONING kompletne i spojne.
- Examples basic/complete/secure + feature-specific gotowe i uruchamialne.
- Testy unit + integration + negative przechodza lokalnie.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md` (status + statystyki)
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-redis-cache.md`
- `modules/README.md` (nowy modul w tabeli AzureRM)
- `README.md` (badges + tabela "Available Modules")
