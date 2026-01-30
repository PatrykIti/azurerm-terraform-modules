# TASK-019: Azure Monitor Data Collection Rule (DCR) + Data Collection Endpoint (DCE) modules
# FileName: TASK-019_DCR_DCE_Modules.md

**Priority:** Medium  
**Category:** New Modules / Monitoring  
**Estimated Effort:** Large  
**Dependencies:** -  
**Status:** Done

---

## Cel

Stworzyc dwa oddzielne moduly zgodne z repo standardami:
- `modules/azurerm_monitor_data_collection_rule`
- `modules/azurerm_monitor_data_collection_endpoint`

Zasada atomic modules: jeden primary resource per modul. DCR i DCE to osobne
zasoby Azure Monitor, wiec maja osobne moduly. DCR moze (opcjonalnie) wskazywac
`data_collection_endpoint_id` jako zaleznosc, ale DCE nie jest bundlowane.

Moduly musza byc zgodne z:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

---

## Zakres (Provider Resources)

**DCE module (primary):**
- `azurerm_monitor_data_collection_endpoint`

**DCR module (primary):**
- `azurerm_monitor_data_collection_rule`

**Out-of-scope (oba moduly):**
- Private endpoints, RBAC, role assignments, VNet/DNS glue
- Log Analytics workspace / destinations tworzone osobno
- Alerts, action groups, dashboards

---

## Zalozenia i decyzje

1) **Atomic scope**  
   Jeden primary resource na modul. DCR i DCE osobno.

2) **Brak cross-resource glue**  
   Powiazania (np. DCR -> DCE) tylko przez ID inputy, bez tworzenia zaleznosci w module.

3) **Security-first**  
   Bez sekretow. Domyslne ustawienia powinny byc bezpieczne; ryzyka opisane w `SECURITY.md`.

4) **Spojny UX**  
   Inputs zgrupowane logicznie, walidacje w `variables.tf`, brak defaultow w `locals`.

---

## Zakres i deliverables

### TASK-019-1: Discovery / feature inventory

**Cel:** Potwierdzic schema provider `azurerm` 4.57.0 dla DCR i DCE.

**Do zrobienia:**
- Sprawdzic wymagane pola i dopuszczalne wartosci w:
  - `azurerm_monitor_data_collection_endpoint`
  - `azurerm_monitor_data_collection_rule`
- Potwierdzic wspierane bloki/nesting w DCR:
  - destinations (Log Analytics / Event Hub / Storage / Monitor metrics / etc.)
  - data sources (performance counters, syslog, windows_event_log, extensions, etc.)
  - data flows / streams / transformations
  - `data_collection_endpoint_id` (opcjonalny)
- Potwierdzic wsparcie `timeouts` oraz limity walidacji.

---

### TASK-019-2: Scaffold modulu DCE

**Cel:** Stworzyc pelna strukture `modules/azurerm_monitor_data_collection_endpoint`.

**Checklist:**
- [ ] `scripts/create-new-module.sh` (obowiazkowo)
- [ ] `module.json`:
  - name: `azurerm_monitor_data_collection_endpoint`
  - commit_scope: `monitor-dce`
  - tag_prefix: `DCEv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] Pliki bazowe + docs (`README.md`, `SECURITY.md`, `docs/IMPORT.md`, itd.)
- [ ] Porownac pliki konfiguracyjne, testowe i tooling z
      `modules/azurerm_postgresql_flexible_server` (fixtures, tests/Makefile,
      tooling scripts, test_config.yaml, run_tests_*.sh) i doprowadzic do pelnej
      zgodnosci struktury i targetow.

---

### TASK-019-3: Implementacja DCE (variables + main + outputs)

**Cel:** Wsparcie wszystkich pol DCE wprost z provider schema.

**Do zrobienia:**
- Inputs: core (`name`, `resource_group_name`, `location`, `tags`), network/public access, description/kind (wg schema).
- Walidacje: nazwa, dozwolone wartosci (wg discovery).
- Outputs: `id`, `name`, `configuration_access`, `logs_ingestion` (wg schema).

---

### TASK-019-4: Scaffold modulu DCR

**Cel:** Stworzyc pelna strukture `modules/azurerm_monitor_data_collection_rule`.

**Checklist:**
- [ ] `scripts/create-new-module.sh` (obowiazkowo)
- [ ] `module.json`:
  - name: `azurerm_monitor_data_collection_rule`
  - commit_scope: `monitor-dcr`
  - tag_prefix: `DCRv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] Pliki bazowe + docs (`README.md`, `SECURITY.md`, `docs/IMPORT.md`, itd.)
- [ ] Porownac pliki konfiguracyjne, testowe i tooling z
      `modules/azurerm_postgresql_flexible_server` (fixtures, tests/Makefile,
      tooling scripts, test_config.yaml, run_tests_*.sh) i doprowadzic do pelnej
      zgodnosci struktury i targetow.

---

### TASK-019-5: Implementacja DCR (variables + main + outputs)

**Cel:** Wsparcie pelnego API DCR zgodnie z provider schema.

**Do zrobienia:**
- Inputs zgrupowane logicznie:
  - core: `name`, `resource_group_name`, `location`, `tags`
  - optional: `data_collection_endpoint_id`
  - `destinations` (object/list zgodnie z schema)
  - `data_sources` (object/list zgodnie z schema)
  - `data_flow` (list(object)) + walidacje stream/destination combos
  - `stream_declaration` / `transform_kql` (jesli wspierane)
- Walidacje: nazwy, dozwolone values, wymagane kombinacje.
- Preconditions w `main.tf` dla cross-field rules (np. destinations + data_flow).
- Outputs: `id`, `name`, `immutable_id`, `endpoint_id`, `destinations`, `data_sources` (wg schema).

---

### TASK-019-6: Examples (basic/complete/secure) + fixtures

**Cel:** Przyklady uruchamialne lokalnie, zgodne z guide.

**DCE examples:**
- `basic`: minimalny DCE
- `complete`: jawne ustawienia (public access, description, tags)
- `secure`: private networking (poza modulem) + DCE

**DCR examples:**
- `basic`: DCR z Log Analytics destination
- `complete`: DCR z wieloma destinations + data sources + data flows
- `secure`: DCR + DCE (DCE jako osobny modul), bez public access
- `syslog` lub `windows-event-log`: feature-specific example pokazujacy alternatywny data source

**Fixtures:** analogicznie do examples (basic/complete/secure).

---

### TASK-019-7: Testy (unit + integration)

**Cel:** Zgodnosc z `docs/TESTING_GUIDE`.

**Unit tests:**
- Walidacje nazw i dozwolonych values.
- Walidacje cross-field (np. data_flow wymaga destinations).

**Integration tests:**
- Fixtures `basic`, `complete`, `secure` dla obu modulow.
- Weryfikacja outputow + istnienia zasobow.

---

### TASK-019-8: Dokumentacja i release automation

**Cel:** Kompletny zestaw docs zgodny z MODULE_GUIDE.

**Do zrobienia:**
- `README.md` + markers + Module Documentation + Security Considerations.
- `docs/README.md` (overview + managed resources + out-of-scope).
- `docs/IMPORT.md` (import blocks + minimal config).
- `SECURITY.md` (ryzyka, secure usage).
- `generate-docs.sh` + `.terraform-docs.yml` + examples docs.

---

## Potwierdzone decyzje

1) Dwa osobne moduly: `DCR` i `DCE` (bez modulu laczonego).
2) Tag prefixy w `module.json`: `DCRv` i `DCEv`.
3) Dodatkowy feature-specific example dla DCR (np. syslog/windows_event_log).
