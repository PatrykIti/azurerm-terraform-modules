# TASK-032: Azure Container Registry module (full feature scope)
# FileName: TASK-032_Container_Registry_Module.md

**Priority:** High  
**Category:** New Module / Containers  
**Estimated Effort:** Large  
**Dependencies:** -  
**Status:** To Do

---

## Cel

Stworzyc nowy modul `modules/azurerm_container_registry` zgodny z:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

Modul ma pokrywac wszystkie funkcje dostepne w `azurerm_container_registry`
oraz sub-resources powiazane bezposrednio z ACR (pelne zarzadzanie ACR).
AKS jest wzorcem struktury i testow; wszystkie odstepstwa musza byc jawnie
udokumentowane.

---

## Zakres (Provider Resources)

**Primary:**
- `azurerm_container_registry`

**Powiazane zasoby (w module):**
- `azurerm_container_registry_scope_map`
- `azurerm_container_registry_token`
- `azurerm_container_registry_webhook`
- `azurerm_container_registry_task` (jesli wspierane)
- `azurerm_container_registry_agent_pool` (jesli wspierane)
- `azurerm_container_registry_cache_rule` (jesli wspierane)
- `azurerm_container_registry_replication` (jesli oddzielny resource w providerze)
- `azurerm_monitor_diagnostic_setting`

**Potwierdzic w providerze (azurerm 4.57.0, docs/scan):**
- Dokladny zestaw ACR sub-resources oraz ich nazwy.
- Czy georeplication jest blokiem w `azurerm_container_registry` czy oddzielnym resource.
- Czy `cache_rule`, `agent_pool`, `task` sa dostepne w tej wersji providera.

---

## Zalozenia i decyzje

1) **Atomic scope**  
   Modul zarzadza jednym ACR jako primary resource. Dodatkowe zasoby
   tylko wtedy, gdy sa bezposrednio powiazane z ACR (scope maps, tokens,
   webhooks, tasks, agent pools, cache rules, diagnostic settings).

2) **Brak cross-resource glue**  
   Poza modulem: private endpoints, Private DNS Zone, RBAC/role assignments,
   Key Vault, VNet/Subnet, Log Analytics Workspace. Pokazujemy je tylko
   w examples jako zasoby pomocnicze.

3) **Security-first**  
   Secure defaults gdzie to mozliwe. Publiczny dostep tylko przez jawne inputy.
   Wszystkie ryzyka opisane w `SECURITY.md`.

4) **Spojny styl**  
   Listy obiektow + `for_each` po `name`, walidacje w `variables.tf`, zaleznosci
   cross-field jako `lifecycle` preconditions w `main.tf`.

---

## Feature matrix (musi byc pokryty)

- SKU (Basic/Standard/Premium) + lokalna autoryzacja/admin user
- Public network access toggle + network rules (default_action, ip rules, bypass)
- Geo-replication (locations, tags, zone redundancy, regional endpoint)
- Retention policy (untagged manifests) 
- Identity (SystemAssigned/UserAssigned)
- Encryption / CMK (Key Vault key + identity) (jesli wspierane)
- Data endpoint enabled (jesli wspierane)
- Anonymous pull (jesli wspierane)
- Trust policy / content trust (jesli wspierane)
- Export policy (jesli wspierane)
- Zone redundancy (jesli wspierane)
- Tasks + triggers (docker/file/encoded steps, source/timer/base image triggers)
- Agent pools (size/tier/OS/subnet, wg provider)
- Scope maps + tokens (akcje i powiazania)
- Webhooks (actions, scope, auth headers)
- Cache rules (jesli wspierane)
- Diagnostic settings (log/metric categories)
- Tags i timeouts

---

## Zakres i deliverables

### TASK-032-1: Discovery / feature inventory

**Cel:** Potwierdzic pelny zakres funkcji provider `azurerm` dla ACR i sub-resources.

**Do zrobienia:**
- Sprawdzic schema provider `azurerm` (doc lub `terraform providers schema -json`)
  dla `azurerm_container_registry` i powiazanych zasobow.
- Potwierdzic dokladne nazwy oraz status wsparcia dla:
  - `azurerm_container_registry_task`
  - `azurerm_container_registry_agent_pool`
  - `azurerm_container_registry_cache_rule`
  - `azurerm_container_registry_replication` (jesli istnieje)
- Spisac finalny zestaw pol i ograniczen (allowed values, required combos).
- Zaktualizowac listy walidacji, preconditions i examples na bazie realnych pol.

---

### TASK-032-2: Scaffold modulu + pliki bazowe

**Cel:** Stworzyc pelna strukture modulu zgodna z guide.

**Checklist:**
- [ ] `modules/azurerm_container_registry/` utworzony przez
      `scripts/create-new-module.sh` (wymagane).
- [ ] `module.json`:
  - name: `azurerm_container_registry`
  - commit_scope: `container-registry`
  - tag_prefix: `ACRv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] `.releaserc.js`, `.terraform-docs.yml`, `Makefile`, `generate-docs.sh`
      zgodne z AKS.
- [ ] Pliki bazowe: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`,
      `VERSIONING.md`, `SECURITY.md`, `docs/IMPORT.md`.

---

### TASK-032-3: Core resource `azurerm_container_registry`

**Cel:** Implementacja pelnego API ACR w `main.tf` + walidacje w `variables.tf`.

**Zakres (przykladowy podzial inputow):**
- **core**: `name`, `resource_group_name`, `location`, `tags`
- **sku/admin**: `sku`, `admin_enabled`
- **network**: `public_network_access_enabled`, `network_rule_set` (default_action, ip_rules),
  `network_rule_bypass_option` (jesli wspierane)
- **geo_replications**: list(object({ location, tags?, zone_redundancy_enabled?, regional_endpoint_enabled? }))
- **retention_policy**: `retention_policy` (days, enabled)
- **identity**: `type`, `identity_ids`
- **encryption**: `key_vault_key_id`, `identity_client_id` lub `identity_id` (wg schema)
- **feature_flags**: `data_endpoint_enabled`, `anonymous_pull_enabled`,
  `trust_policy`, `export_policy`, `zone_redundancy_enabled` (jesli wspierane)
- **timeouts** (optional)

**Walidacje i preconditions (must-have):**
- Nazwa ACR zgodna z rules Azure (lowercase, length/regex).
- `sku` w dozwolonych wartosciach.
- `admin_enabled` tylko gdy wspierane w SKU (wg provider).
- `geo_replications` tylko dla Premium i bez duplikatow regionu.
- `network_rule_set` wymaga jawnego `public_network_access_enabled = true` (jesli wymagane).
- `identity_ids` tylko gdy `type` zawiera `UserAssigned`.
- CMK/encryption wymaga `identity` i Premium SKU.
- `retention_policy.days` w dozwolonym zakresie.
- Feature flags (anonymous pull, trust/export) tylko gdy wspierane w SKU.

**Implementation notes:**
- `locals` dla flag i map wynikowych.
- `lifecycle` preconditions dla regul cross-field.
- Nazwy zasobow i iteratorow zgodne z guide (no `this`, no skroty).

---

### TASK-032-4: Sub-resources (scope maps, tokens, webhooks, tasks, agent pools, cache rules)

**Cel:** Pelne wsparcie sub-resources zwiazanych z ACR.

**Inputs (propozycje):**
- `scope_maps`: list(object({ name, actions, description? }))
- `tokens`: list(object({ name, scope_map_name?, scope_map_id?, status? }))
- `webhooks`: list(object({ name, service_uri, actions, scope?, status?, custom_headers? }))
- `tasks`: list(object({ name, status?, platform, agent_pool_name?,
    docker_step?, file_step?, encoded_step?, source_trigger?, timer_trigger?,
    base_image_trigger?, registry_credential?, identity? }))
- `agent_pools`: list(object({ name, count, tier?, os?, subnet_id? })) (jesli wspierane)
- `cache_rules`: list(object({ name, source_registry, target_repo?, credential_set? })) (jesli wspierane)
- `replications`: list(object({ location, zone_redundancy_enabled?, regional_endpoint_enabled?, tags? }))
  (tylko jesli `azurerm_container_registry_replication` istnieje jako resource)

**Wymagania:**
- `for_each` po `name` + walidacja unikalnosci.
- Walidacje zakresow (np. nazwy, listy niepuste, poprawne URI dla webhooks).
- `tokens` powiazane z `scope_maps` (po ID lub nazwa -> mapowanie).
- `tasks` walidowane pod katem zdefiniowania dokladnie jednego typu step.
- Agent pools i cache rules tylko gdy wspierane w provider schema.

---

### TASK-032-5: Diagnostic settings (inline, AKS pattern)

**Cel:** Wbudowane `azurerm_monitor_diagnostic_setting` dla ACR.

**Do zrobienia:**
- `diagnostic_settings` input (lista obiektow) jak w AKS.
- `data.azurerm_monitor_diagnostic_categories` + filtracja kategorii.
- `areas` -> mapowanie na log/metric categories (lub default `all`).
- `diagnostic_settings_skipped` output jak w AKS.

---

### TASK-032-6: Dokumentacja modulu

**Cel:** Kompletne docs zgodne z MODULE_GUIDE.

**Do zrobienia:**
- `README.md` z wymaganymi markerami i sekcjami (Module Documentation, Security Considerations).
- `docs/README.md`:
  - Overview, Managed Resources, Usage Notes
  - Out-of-scope zasoby (private endpoints, Private DNS, RBAC).
- `docs/IMPORT.md` wg AKS (import blocks + ID collection).
- `SECURITY.md`:
  - posture (public access, admin user, tokens/permissions)
  - secure example
  - checklist i typowe bledy
- `CONTRIBUTING.md` i `VERSIONING.md` zgodne z `module.json`.

---

### TASK-032-7: Examples (basic/complete/secure + feature-specific)

**Cel:** Przyklady zgodne z guide, uruchamialne lokalnie.

**Wymagane:**
- `examples/basic`: minimalny ACR (Basic/Standard, admin disabled).
- `examples/complete`: Premium + geo replications + identity + CMK + retention + diag settings.
- `examples/secure`: public access disabled + private endpoint (poza modulem w example).

**Feature-specific (propozycje):**
- `examples/scope-map-token`
- `examples/webhook`
- `examples/task`
- `examples/agent-pool` (jesli wspierane)
- `examples/cache-rule` (jesli wspierane)
- `examples/geo-replication` (jesli oddzielny resource)

**Wymagania wspolne:**
- `source = "../.."`, stale nazwy, `README.md` + `.terraform-docs.yml`.
- Zasoby pomocnicze (Key Vault, PE, DNS, VNet/Subnet) tworzone lokalnie w example.

---

### TASK-032-8: Testy (unit + integration + negative)

**Cel:** Zgodnosc z `docs/TESTING_GUIDE`.

**Unit tests (tftest.hcl):**
- walidacje nazwy i SKU.
- reguly public access + network_rule_set.
- reguly identity/CMK.
- walidacje retention policy.

**Integration / Terratest:**
- fixtures: `basic`, `complete`, `secure`, `scope-map-token`, `webhook`, `task`,
  `agent-pool` (jesli wspierane), `cache-rule` (jesli wspierane), `geo-replication`.
- weryfikacja:
  - ACR properties (sku, admin, network, retention)
  - sub-resources (count + podstawowe pola)
  - diag settings (log/metric categories)

**Negatywne:**
- zly format nazwy
- niepoprawny SKU
- CMK bez identity
- geo_replications bez Premium

---

### TASK-032-9: Automatyzacja i release

**Cel:** Spojna automatyzacja i dokumentacja.

**Do zrobienia:**
- `tests/Makefile`, `test_env.sh`, `run_tests_*` jak w AKS.
- `generate-docs.sh` zgodny z guide.
- Aktualizacja `docs/_TASKS/README.md` po wdrozeniu.
- Wpis w `docs/_CHANGELOG/` dla nowego modulu.

---

## Acceptance Criteria

- Modul `modules/azurerm_container_registry` spelnia layout z MODULE_GUIDE.
- Pokrycie wszystkich funkcji z feature matrix + potwierdzonych w provider schema.
- README/SECURITY/IMPORT/CONTRIBUTING/VERSIONING kompletne i spojne.
- Examples basic/complete/secure + feature-specific gotowe i uruchamialne.
- Testy unit + integration + negative przechodza lokalnie.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md` (status + statystyki)
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-container-registry.md`
- `modules/README.md` (nowy modul w tabeli AzureRM)
- `README.md` (badges + tabela "Available Modules")
