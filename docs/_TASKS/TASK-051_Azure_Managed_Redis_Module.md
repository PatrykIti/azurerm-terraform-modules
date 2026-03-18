# TASK-051: Azure Managed Redis module (full feature scope)
# FileName: TASK-051_Azure_Managed_Redis_Module.md

**Priority:** High  
**Category:** New Module / Cache  
**Estimated Effort:** Large  
**Dependencies:** TASK-003 (module scaffold generator baseline)  
**Status:** Planned

---

## Cel

Stworzyc nowy modul `modules/azurerm_managed_redis` zgodny z:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

Modul ma pokrywac caly aktualnie wspierany zakres Azure Managed Redis w
`azurerm` `4.57.0`, czyli glowny resource `azurerm_managed_redis` oraz
powiazany resource do zarzadzania membership geo-replikacji
`azurerm_managed_redis_geo_replication`.

AKS jest wzorcem struktury, a `azurerm_postgresql_flexible_server` jest
wzorcem dla server-scoped child resources, docs i test harnessu.

---

## Zakres (Provider Resources)

**Primary:**
- `azurerm_managed_redis`

**Powiazane zasoby (w module):**
- `azurerm_managed_redis_geo_replication`
- `azurerm_monitor_diagnostic_setting`

**Potwierdzone w providerze (azurerm 4.57.0, schema + official docs):**
- `azurerm_managed_redis`
- `azurerm_managed_redis_geo_replication`
- `data.azurerm_managed_redis` (tylko lookup; out-of-scope dla samego modulu)

**Out-of-scope:**
- Legacy Redis Enterprise:
  - `azurerm_redis_enterprise_cluster`
  - `azurerm_redis_enterprise_database`
- Private endpoints, Private DNS, VNet/subnet glue
- RBAC/role assignments
- Log Analytics workspace, Event Hub namespace, Storage Account jako zewnetrzne zaleznosci diagnostyki
- Tworzenie dodatkowych instancji Managed Redis w module tylko po to, aby zestawic geo-replikacje

---

## Zalozenia i decyzje

1) **Atomic scope**  
   Modul zarzadza jedna instancja Managed Redis jako primary resource.
   Geo-replikacja jest opcjonalnym child resource zarzadzajacym membership dla
   tej instancji, ale nie tworzy wewnatrz modulu dodatkowych klastrow.

2) **Scaffold tylko przez generator repo**  
   Szkielet modulu musi zostac utworzony przez:

```bash
./scripts/create-new-module.sh \
  azurerm_managed_redis \
  "Managed Redis" \
  AMR \
  managed-redis \
  "Azure Managed Redis Terraform module with enterprise-grade features"
```

   Wszelkie dalsze zmiany sa nanoszone na wygenerowany scaffold, a nie przez
   reczne tworzenie struktury od zera.

3) **Brak cross-resource glue**  
   Poza modulem zostaja private endpoints, DNS, RBAC, VNet-y, dodatkowe
   Managed Redis instancje do geo-replikacji oraz destination resources dla
   diagnostic settings. Mozna je pokazac tylko w examples.

4) **Security-first**  
   Bezpieczne defaulty sa preferowane: `high_availability_enabled = true`,
   `public_network_access = "Enabled"` tylko jako jawny wybor, jawne
   walidacje dla access keys, CMK, persistence i geo-replikacji.

5) **Source of truth**  
   Zakres funkcjonalny i walidacje opieramy na realnym provider schema
   `azurerm 4.57.0` oraz official docs dla `managed_redis` i
   `managed_redis_geo_replication`.

---

## Feature matrix (musi byc pokryty)

- `sku_name` dla rodzin `Balanced_*`, `ComputeOptimized_*`, `FlashOptimized_*`, `MemoryOptimized_*`
- `high_availability_enabled`
- `public_network_access`
- `identity`
- `customer_managed_key`
- `default_database`
- `default_database.access_keys_authentication_enabled`
- `default_database.client_protocol`
- `default_database.clustering_policy` z obsluga `EnterpriseCluster`, `OSSCluster`, `NoCluster`
- `default_database.eviction_policy`
- `default_database.geo_replication_group_name`
- `default_database.persistence_append_only_file_backup_frequency`
- `default_database.persistence_redis_database_backup_frequency`
- `default_database.module` (`RedisBloom`, `RedisTimeSeries`, `RediSearch`, `RedisJSON`)
- `tags`
- `timeouts`
- `azurerm_managed_redis_geo_replication.linked_managed_redis_ids`
- Diagnostic settings dla logow i metryk
- Outputs dla hosta, database block, identity, geo-replication i sensitive access keys

---

## Pliki fizyczne

### Pliki tworzone przez scaffold generator

Generator `scripts/create-new-module.sh` utworzy i wypelni placeholdery dla:

- `modules/azurerm_managed_redis/main.tf`
- `modules/azurerm_managed_redis/variables.tf`
- `modules/azurerm_managed_redis/outputs.tf`
- `modules/azurerm_managed_redis/versions.tf`
- `modules/azurerm_managed_redis/README.md`
- `modules/azurerm_managed_redis/CHANGELOG.md`
- `modules/azurerm_managed_redis/CONTRIBUTING.md`
- `modules/azurerm_managed_redis/VERSIONING.md`
- `modules/azurerm_managed_redis/SECURITY.md`
- `modules/azurerm_managed_redis/module.json`
- `modules/azurerm_managed_redis/.releaserc.js`
- `modules/azurerm_managed_redis/.terraform-docs.yml`
- `modules/azurerm_managed_redis/Makefile`
- `modules/azurerm_managed_redis/generate-docs.sh`
- `modules/azurerm_managed_redis/docs/README.md`
- `modules/azurerm_managed_redis/examples/basic/*`
- `modules/azurerm_managed_redis/examples/complete/*`
- `modules/azurerm_managed_redis/examples/secure/*`
- `modules/azurerm_managed_redis/tests/go.mod`
- `modules/azurerm_managed_redis/tests/go.sum`
- `modules/azurerm_managed_redis/tests/managed_redis_test.go`
- `modules/azurerm_managed_redis/tests/integration_test.go`
- `modules/azurerm_managed_redis/tests/performance_test.go`
- `modules/azurerm_managed_redis/tests/test_helpers.go`
- `modules/azurerm_managed_redis/tests/Makefile`
- `modules/azurerm_managed_redis/tests/run_tests_parallel.sh`
- `modules/azurerm_managed_redis/tests/run_tests_sequential.sh`
- `modules/azurerm_managed_redis/tests/test_env.sh`
- `modules/azurerm_managed_redis/tests/test_config.yaml`
- `modules/azurerm_managed_redis/tests/README.md`
- `modules/azurerm_managed_redis/tests/unit/defaults.tftest.hcl`
- `modules/azurerm_managed_redis/tests/unit/naming.tftest.hcl`
- `modules/azurerm_managed_redis/tests/unit/validation.tftest.hcl`
- `modules/azurerm_managed_redis/tests/unit/outputs.tftest.hcl`
- `modules/azurerm_managed_redis/tests/fixtures/basic/*`
- `modules/azurerm_managed_redis/tests/fixtures/complete/*`
- `modules/azurerm_managed_redis/tests/fixtures/secure/*`
- `modules/azurerm_managed_redis/tests/fixtures/network/main.tf`
- `modules/azurerm_managed_redis/tests/fixtures/negative/main.tf`

### Pliki do dodania lub przepisywania recznie po scaffoldzie

- `modules/azurerm_managed_redis/diagnostics.tf`
- `modules/azurerm_managed_redis/docs/IMPORT.md`
- `modules/azurerm_managed_redis/examples/diagnostic-settings/main.tf`
- `modules/azurerm_managed_redis/examples/diagnostic-settings/variables.tf`
- `modules/azurerm_managed_redis/examples/diagnostic-settings/outputs.tf`
- `modules/azurerm_managed_redis/examples/diagnostic-settings/README.md`
- `modules/azurerm_managed_redis/examples/diagnostic-settings/.terraform-docs.yml`
- `modules/azurerm_managed_redis/examples/customer-managed-key/main.tf`
- `modules/azurerm_managed_redis/examples/customer-managed-key/variables.tf`
- `modules/azurerm_managed_redis/examples/customer-managed-key/outputs.tf`
- `modules/azurerm_managed_redis/examples/customer-managed-key/README.md`
- `modules/azurerm_managed_redis/examples/customer-managed-key/.terraform-docs.yml`
- `modules/azurerm_managed_redis/examples/geo-replication/main.tf`
- `modules/azurerm_managed_redis/examples/geo-replication/variables.tf`
- `modules/azurerm_managed_redis/examples/geo-replication/outputs.tf`
- `modules/azurerm_managed_redis/examples/geo-replication/README.md`
- `modules/azurerm_managed_redis/examples/geo-replication/.terraform-docs.yml`
- `modules/azurerm_managed_redis/tests/unit/default_database.tftest.hcl`
- `modules/azurerm_managed_redis/tests/unit/diagnostic_settings.tftest.hcl`
- `modules/azurerm_managed_redis/tests/unit/geo_replication.tftest.hcl`
- `modules/azurerm_managed_redis/tests/fixtures/geo-replication/main.tf`
- `modules/azurerm_managed_redis/tests/fixtures/geo-replication/variables.tf`
- `modules/azurerm_managed_redis/tests/fixtures/geo-replication/outputs.tf`
- `modules/azurerm_managed_redis/tests/fixtures/geo-replication/README.md`

**Uwaga:**  
Scaffold wygeneruje tez genericzne pliki, ktore beda wymagaly przepisu pod ten
resource, zwlaszcza:
- `examples/basic/*`
- `examples/complete/*`
- `examples/secure/*`
- `tests/fixtures/network/main.tf`
- `tests/fixtures/negative/main.tf`
- `tests/unit/*.tftest.hcl`
- `tests/managed_redis_test.go`

---

## Zakres i deliverables

### TASK-051-1: Discovery / contract freeze

**Cel:** Zamknac kontrakt providera i ograniczenia biznesowe przed implementacja.

**Do zrobienia:**
- Potwierdzic schema provider `azurerm` dla:
  - `azurerm_managed_redis`
  - `azurerm_managed_redis_geo_replication`
- Potwierdzic official docs dla:
  - `default_database`
  - `clustering_policy`
  - `module`
  - persistence AOF/RDB
  - geo-replication
- Spisac finalne dozwolone wartosci:
  - `public_network_access`
  - `client_protocol`
  - `clustering_policy`
  - `eviction_policy`
  - `identity.type`
  - `module.name`
- Potwierdzic ograniczenia:
  - geo-replikacja wymaga `Balanced_B3` lub wyzej
  - geo-replikacja i persistence sa wzajemnie sprzeczne
  - tylko `RediSearch` i `RedisJSON` sa dozwolone z geo-replikacja
  - `linked_managed_redis_ids` max `4`

---

### TASK-051-2: Scaffold modulu + bazowe pliki

**Cel:** Utworzyc zgodny scaffold przez repo generator i spisac wynik.

**Checklist:**
- [ ] Uruchomic `scripts/create-new-module.sh` z ustalonymi argumentami:
  - module name: `azurerm_managed_redis`
  - display name: `Managed Redis`
  - prefix: `AMR`
  - commit scope: `managed-redis`
  - description: `Azure Managed Redis Terraform module with enterprise-grade features`
- [ ] Zweryfikowac wygenerowany `module.json`:
  - name: `azurerm_managed_redis`
  - title: `Managed Redis`
  - commit_scope: `managed-redis`
  - tag_prefix: `AMRv`
- [ ] Zweryfikowac, ze scaffold zawiera wymagane pliki bazowe i test harness.
- [ ] Nadpisac lub dopisac pliki, ktorych generator nie tworzy (`diagnostics.tf`, `docs/IMPORT.md`, feature-specific examples, dodatkowe unit tests).

---

### TASK-051-3: Core resource `azurerm_managed_redis`

**Cel:** Implementacja pelnego API Managed Redis w `main.tf` + walidacje w `variables.tf`.

**Zakres (propozycja inputow):**
- **core**: `name`, `resource_group_name`, `location`, `tags`
- **managed_redis**:
  - `sku_name`
  - `high_availability_enabled`
  - `public_network_access`
  - `timeouts`
- **identity**
- **customer_managed_key**
- **default_database**

**Walidacje i preconditions (must-have):**
- Nazwa zgodna z zasadami Azure dla Managed Redis.
- `public_network_access` tylko `Enabled` lub `Disabled`.
- `identity.type` tylko `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned`.
- Dla `UserAssigned` lub `SystemAssigned, UserAssigned` wymagane `identity_ids`.
- `customer_managed_key` wymaga `identity` z `UserAssigned`.
- `customer_managed_key.user_assigned_identity_id` musi wystepowac w `identity.identity_ids`.

---

### TASK-051-4: `default_database` + walidacje funkcjonalne

**Cel:** Pelne wsparcie DB blocka z twardymi walidacjami i sensownymi defaults.

**Zakres:**
- `access_keys_authentication_enabled`
- `client_protocol`
- `clustering_policy`
- `eviction_policy`
- `geo_replication_group_name`
- `persistence_append_only_file_backup_frequency`
- `persistence_redis_database_backup_frequency`
- `module` list

**Wymagania:**
- `default_database` domyslnie obecne, ale musi byc mozliwosc ustawienia `null`.
- `clustering_policy` wspiera `NoCluster`.
- AOF i RDB sa wzajemnie wykluczone.
- Persistence nie moze byc wlaczone razem z `geo_replication_group_name`.
- `module` max `4`.
- `module.name` tylko:
  - `RedisBloom`
  - `RedisTimeSeries`
  - `RediSearch`
  - `RedisJSON`
- Przy geo-replikacji dopuszczalne moduly tylko:
  - `RediSearch`
  - `RedisJSON`

---

### TASK-051-5: Geo-replikacja jako osobny child resource

**Cel:** Wystawic opcjonalne zarzadzanie membership geo-replication group bez lamania atomic boundary.

**Input (propozycja):**
- `geo_replication = object({ linked_managed_redis_ids = set(string), timeouts = optional(object(...)) })`

**Wymagania:**
- Resource `azurerm_managed_redis_geo_replication` tworzony tylko gdy input nie jest `null`.
- `managed_redis_id` wskazuje lokalny `azurerm_managed_redis`.
- `linked_managed_redis_ids` przyjmuje tylko zewnetrzne IDs innych instancji.
- Walidacja max `4` linked IDs.
- Walidacja, ze `default_database.geo_replication_group_name` jest ustawione, gdy geo-replication resource jest wlaczony.
- Docs musza wyraznie ostrzegac, ze linking powoduje utrate cache data i chwilowy outage.

---

### TASK-051-6: Diagnostic settings (inline, repo pattern)

**Cel:** Wbudowane `azurerm_monitor_diagnostic_setting` dla Managed Redis.

**Do zrobienia:**
- Dodac `monitoring` input zgodny z patternem AKS/PostgreSQL.
- Stworzyc `diagnostics.tf`.
- Tworzyc diagnostic settings tylko wtedy, gdy dostarczono kategorie logow lub metryk.
- Dodac output `diagnostic_settings_skipped`.

---

### TASK-051-7: Outputs

**Cel:** Wystawic komplet outputs zgodny z realnym surface modułu.

**Outputs must-have:**
- `id`
- `name`
- `location`
- `resource_group_name`
- `hostname`
- `sku_name`
- `high_availability_enabled`
- `public_network_access`
- `identity`
- `customer_managed_key`
- `default_database`
- `geo_replication`
- `diagnostic_settings_skipped`
- `tags`

**Security:**
- access keys z `default_database` musza byc oznaczone jako `sensitive`.
- `try()` dla outputs opcjonalnych / warunkowych.

---

### TASK-051-8: Dokumentacja modulu

**Cel:** Kompletna dokumentacja zgodna z repo i realnym zakresem providerowym.

**Do zrobienia:**
- `README.md` z markerami:
  - `BEGIN_VERSION`
  - `BEGIN_EXAMPLES`
  - `BEGIN_TF_DOCS`
- `docs/README.md`:
  - overview
  - managed resources
  - architecture / scope boundary
  - out-of-scope
- `docs/IMPORT.md`:
  - import `azurerm_managed_redis`
  - import `azurerm_managed_redis_geo_replication`
  - minimal `main.tf`
  - `import` blocks / CLI examples
- `SECURITY.md`:
  - public network access
  - access keys auth
  - CMK + UAI requirements
  - persistence i secret material w state
  - geo-replication outage/data-loss caveat
- `CONTRIBUTING.md` i `VERSIONING.md` dopasowac do finalnego `module.json`

---

### TASK-051-9: Examples (basic/complete/secure + feature-specific)

**Wymagane:**
- `examples/basic`
- `examples/complete`
- `examples/secure`

**Feature-specific:**
- `examples/diagnostic-settings`
- `examples/customer-managed-key`
- `examples/geo-replication`

**Wymagania wspolne:**
- `source = "../../"`
- stale nazwy zasobow w examples
- lokalne tworzenie zaleznosci zewnetrznych, gdy to potrzebne
- `README.md` i `.terraform-docs.yml` dla kazdego example

**Scenariusze:**
- `basic`: minimalny deployment z default DB
- `complete`: HA + DB config + modules + monitoring
- `secure`: `public_network_access = "Disabled"` + UAI + CMK
- `diagnostic-settings`: same diagnostics destinations i kategorie
- `customer-managed-key`: Key Vault + UAI + CMK wiring
- `geo-replication`: dwa wywolania modulu + jedno linkowanie przez IDs

---

### TASK-051-10: Testy (unit + integration + negative)

**Unit tests (`terraform test`):**
- defaulty top-level
- walidacje enumow
- `NoCluster` acceptance w `clustering_policy`
- konflikt AOF vs RDB
- konflikt persistence vs geo-replication
- CMK wymaga UAI
- geo-replication wymaga `geo_replication_group_name`
- outputs sensitive + conditional handling
- diagnostic settings skip logic

**Integration / Terratest:**
- fixtures:
  - `basic`
  - `complete`
  - `secure`
  - `geo-replication`
- weryfikacja:
  - hostname
  - sku
  - HA
  - public network mode
  - identity / CMK config
  - geo replication resource state

**Negatywne:**
- geo-replication bez group name
- AOF i RDB razem
- persistence z geo-replication
- CMK bez UAI
- niepoprawny `public_network_access`

---

### TASK-051-11: Automatyzacja i repo docs po domknieciu

**Cel:** Zamknac task zgodnie z konwencja repo dla nowego modulu.

**Do zrobienia po implementacji:**
- `terraform fmt`
- `terraform validate`
- `terraform test`
- odswiezenie docs przez `generate-docs.sh` / repo wrapper
- aktualizacja `docs/_TASKS/README.md`
- dodanie wpisu do `docs/_CHANGELOG/README.md`
- dodanie nowego pliku changelog, np. `docs/_CHANGELOG/101-2026-03-18-managed-redis-module.md`
- aktualizacja `modules/README.md`
- aktualizacja `README.md`

---

## Acceptance Criteria

- Modul `modules/azurerm_managed_redis` istnieje i pochodzi z `scripts/create-new-module.sh`.
- Pokrywa caly provider-supported zakres:
  - `azurerm_managed_redis`
  - `azurerm_managed_redis_geo_replication`
- README/SECURITY/IMPORT/CONTRIBUTING/VERSIONING sa kompletne i spojne.
- Examples `basic`, `complete`, `secure` oraz feature-specific sa gotowe i uruchamialne.
- Testy `terraform test` i Terratest pokrywaja core, security i geo-replication.
- Modul nie zawiera cross-resource glue wykraczajacego poza atomic boundary.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/101-2026-03-18-managed-redis-module.md`
- `modules/README.md`
- `README.md`
