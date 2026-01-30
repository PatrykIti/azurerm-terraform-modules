# TASK-037: Azure Event Hubs modules (Namespace + Event Hub)
# FileName: TASK-037_Event_Hubs_Modules.md

**Priority:** High  
**Category:** New Modules / Messaging  
**Estimated Effort:** Large  
**Dependencies:** -  
**Status:** To Do

---

## Cel

Stworzyc dwa oddzielne moduly zgodne z repo standardami:
- `modules/azurerm_eventhub_namespace`
- `modules/azurerm_eventhub`

Zasada atomic modules: jeden primary resource per modul. Namespace i Event Hub to
osobne zasoby -> osobne moduly. Event Hub zalezy od Namespace i dostaje jego
ID/nazwe jako input. Dodatkowe sub-resources tylko te bezposrednio zwiazane z
danym resource.

Moduly musza byc zgodne z:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

---

## Zakres (Provider Resources)

**Namespace module (primary):**
- `azurerm_eventhub_namespace`

**Powiazane zasoby (w module, jesli wspierane w 4.57.0):**
- `azurerm_eventhub_namespace_authorization_rule`
- `azurerm_eventhub_namespace_network_rule_set`
- `azurerm_eventhub_namespace_disaster_recovery_config`
- `azurerm_eventhub_namespace_customer_managed_key` (jesli provider wspiera)
- `azurerm_monitor_diagnostic_setting` (jesli resource wspiera)

**Event Hub module (primary):**
- `azurerm_eventhub`

**Powiazane zasoby (w module):**
- `azurerm_eventhub_consumer_group`
- `azurerm_eventhub_authorization_rule`

**Out-of-scope (oba moduly):**
- Private endpoints, Private DNS Zone + VNet links (osobne moduly)
- RBAC/role assignments, policy, budzety
- Storage Account / Key Vault / Managed Identity provisioning (tylko ID inputy)
- Event Hub Cluster (dedicated) i zasoby spoza Event Hubs

---

## Zalozenia i decyzje

1) **Atomic scope**  
   Jeden primary resource na modul. Namespace i Event Hub osobno.

2) **Brak cross-resource glue**  
   Powiazania realizowane tylko przez ID inputy. Nie tworzymy private endpoints,
   DNS linkow, RBAC ani role assignments w modulach.

3) **Security-first**  
   Secure defaults gdzie to mozliwe. Public access tylko przez jawne inputy.
   Ryzyka i rekomendacje w `SECURITY.md`.

4) **Spojny styl**  
   Listy obiektow + `for_each` po `name`, walidacje w `variables.tf`,
   zaleznosci cross-field jako `lifecycle` preconditions w `main.tf`.

---

## Feature matrix (musi byc pokryty)

**Namespace:**
- name + RG + location + tags
- `sku` + `capacity`
- `auto_inflate_enabled` + `maximum_throughput_units`
- `zone_redundant`
- `kafka_enabled` (jesli wspierane)
- `public_network_access_enabled` / `local_authentication_enabled`
- `minimum_tls_version` (jesli wspierane)
- `identity` (SystemAssigned/UserAssigned)
- `customer_managed_key` (key vault key id + identity)
- `network_rule_set` (default action, ip_rules, vnet_rules, trusted services)
- `disaster_recovery_config` (alias + partner namespace)
- diagnostic settings (jesli wspierane)
- timeouts

**Event Hub:**
- name + namespace id/name + tags
- `partition_count`
- `message_retention` / `retention_in_days` (wg schema)
- `status` (jesli wspierane)
- `capture_description` (enabled, encoding, interval, size_limit, destination)
- consumer groups
- authorization rules
- timeouts

---

## Zakres i deliverables

### TASK-037-1: Discovery / feature inventory

**Cel:** Potwierdzic schema provider `azurerm` 4.57.0 dla Event Hubs.

**Do zrobienia:**
- Sprawdzic schema provider `azurerm` (doc lub `terraform providers schema -json`) dla:
  - `azurerm_eventhub_namespace`
  - `azurerm_eventhub`
  - `azurerm_eventhub_namespace_authorization_rule`
  - `azurerm_eventhub_authorization_rule`
  - `azurerm_eventhub_consumer_group`
  - `azurerm_eventhub_namespace_network_rule_set`
  - `azurerm_eventhub_namespace_disaster_recovery_config`
  - `azurerm_eventhub_namespace_customer_managed_key` (jesli wystepuje)
- Potwierdzic:
  - czy `namespace_id` jest wspierane w `azurerm_eventhub` (vs name + RG).
  - dozwolone values dla `sku`, `minimum_tls_version`, `status`, retention.
  - limity `partition_count` i `message_retention`.
  - wymagane pola dla `capture_description` (storage account/container/format).
  - wymagania CMK i identity (UserAssigned).
  - zasady network rule set (ip/vnet, trusted services).
  - czy namespace wspiera `diagnostic_settings`.
- Spisac finalny zestaw pol i ograniczen (allowed values, required combos).

---

### TASK-037-2: Scaffold modulu Event Hub Namespace

**Cel:** Stworzyc pelna strukture `modules/azurerm_eventhub_namespace`.

**Checklist:**
- [ ] `scripts/create-new-module.sh` (obowiazkowo)
- [ ] `module.json`:
  - name: `azurerm_eventhub_namespace`
  - commit_scope: `eventhub-namespace`
  - tag_prefix: `EHNSv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] Pliki bazowe + docs (`README.md`, `SECURITY.md`, `docs/IMPORT.md`, itd.)
- [ ] Porownac pliki testowe i tooling z
      `modules/azurerm_postgresql_flexible_server` i doprowadzic do pelnej zgodnosci.

---

### TASK-037-3: Implementacja Namespace (variables + main + outputs)

**Cel:** Wsparcie pelnego API `azurerm_eventhub_namespace`.

**Zakres (przykladowy podzial inputow):**
- **core**: `name`, `resource_group_name`, `location`, `tags`
- **sku/capacity**: `sku`, `capacity`, `auto_inflate_enabled`, `maximum_throughput_units`
- **security**: `public_network_access_enabled`, `local_authentication_enabled`, `minimum_tls_version`
- **identity**: `type`, `identity_ids`
- **kafka/zone**: `kafka_enabled`, `zone_redundant` (wg schema)
- **timeouts** (optional)

**Walidacje i preconditions (must-have):**
- Nazwa namespace zgodna z rules Azure (length + regex).
- `auto_inflate_enabled = true` -> wymagany `maximum_throughput_units`.
- `capacity` i `maximum_throughput_units` w dozwolonych zakresach.
- `minimum_tls_version` w dozwolonym zbiorze.

---

### TASK-037-4: Namespace sub-resources

**Cel:** Pelne wsparcie sub-resources zwiazanych z namespace.

**Inputs (propozycje):**
- `namespace_authorization_rules`: list(object({ name, listen, send, manage }))
- `network_rule_set`: object({ default_action, public_network_access_enabled?, trusted_services_allowed?,
    ip_rules = list(string), vnet_rules = list(object({ subnet_id, ignore_missing_vnet_service_endpoint? })) })
- `disaster_recovery_config`: object({ name, partner_namespace_id })
- `customer_managed_key`: object({ key_vault_key_id, user_assigned_identity_id })

**Wymagania:**
- `for_each` po `name` + walidacja unikalnosci.
- Walidacja `partner_namespace_id` i `key_vault_key_id` (format Azure resource ID).
- CMK wymaga `identity` z user-assigned.

---

### TASK-037-5: Diagnostic settings (namespace, inline, AKS pattern)

**Cel:** Wbudowane `azurerm_monitor_diagnostic_setting` dla namespace (jesli wspierane).

**Do zrobienia:**
- `diagnostic_settings` input (lista obiektow) jak w AKS.
- `data.azurerm_monitor_diagnostic_categories` + filtracja kategorii.
- `areas` -> mapowanie na log/metric categories (lub default `all`).
- `diagnostic_settings_skipped` output jak w AKS.

---

### TASK-037-6: Scaffold modulu Event Hub

**Cel:** Stworzyc pelna strukture `modules/azurerm_eventhub`.

**Checklist:**
- [ ] `scripts/create-new-module.sh` (obowiazkowo)
- [ ] `module.json`:
  - name: `azurerm_eventhub`
  - commit_scope: `eventhub`
  - tag_prefix: `EHv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] Pliki bazowe + docs (`README.md`, `SECURITY.md`, `docs/IMPORT.md`, itd.)
- [ ] Porownac pliki testowe i tooling z
      `modules/azurerm_postgresql_flexible_server` i doprowadzic do pelnej zgodnosci.

---

### TASK-037-7: Implementacja Event Hub (variables + main + outputs)

**Cel:** Wsparcie pelnego API `azurerm_eventhub`.

**Zakres (przykladowy podzial inputow):**
- **core**: `name`, `namespace_id` (lub `namespace_name` + `resource_group_name`), `tags`
- **settings**: `partition_count`, `message_retention`, `status`
- **capture**: object({ enabled, encoding, interval_in_seconds, size_limit_in_bytes,
  skip_empty_archives?, destination = object({ storage_account_id, blob_container_name, archive_name_format }) })
- **timeouts** (optional)

**Walidacje i preconditions (must-have):**
- Nazwa event hub zgodna z rules Azure (length + regex).
- `partition_count` i `message_retention` w dozwolonych zakresach.
- `capture.enabled = true` -> wymagany `storage_account_id` + `blob_container_name`.
- `namespace_id` XOR (`namespace_name` + `resource_group_name`) zgodnie ze schema.

---

### TASK-037-8: Event Hub sub-resources (consumer groups + auth rules)

**Cel:** Pelne wsparcie sub-resources zwiazanych z event hub.

**Inputs (propozycje):**
- `consumer_groups`: list(object({ name, user_metadata? }))
- `authorization_rules`: list(object({ name, listen, send, manage }))

**Wymagania:**
- `for_each` po `name` + walidacja unikalnosci.
- Walidacje praw dostepu (listen/send/manage).

---

### TASK-037-9: Dokumentacja modulow

**Cel:** Kompletne docs zgodne z MODULE_GUIDE.

**Do zrobienia (dla kazdego modulu):**
- `README.md` z wymaganymi markerami i sekcjami (Module Documentation, Security Considerations).
- `docs/README.md`:
  - Overview, Managed Resources, Usage Notes
  - Out-of-scope zasoby (private endpoints, DNS, RBAC, itp.).
- `docs/IMPORT.md` wg AKS (import blocks + ID collection).
- `SECURITY.md`:
  - posture (network access, CMK, capture)
  - secure example
  - checklist i typowe bledy
- `CONTRIBUTING.md` i `VERSIONING.md` zgodne z `module.json`.

---

### TASK-037-10: Examples (basic/complete/secure + feature-specific)

**Cel:** Przyklady uruchamialne lokalnie, zgodne z guide.

**Namespace examples:**
- `basic`: minimalny namespace.
- `complete`: auto-inflate + network rules + auth rules + diag settings.
- `secure`: public access off + private endpoint (poza modulem) + CMK (jesli wspierane).

**Event Hub examples:**
- `basic`: event hub w istniejacym namespace.
- `complete`: capture + consumer groups + auth rules.
- `secure`: event hub w namespace z public access off (namespace poza modulem).

**Feature-specific (propozycje):**
- `examples/network-rule-set` (namespace)
- `examples/disaster-recovery` (namespace)
- `examples/capture` (event hub)
- `examples/consumer-groups` (event hub)

**Wymagania wspolne:**
- `source = "../.."`, stale nazwy, `README.md` + `.terraform-docs.yml`.
- Zasoby pomocnicze (storage account, key vault, private endpoint) tworzone lokalnie w example.

---

### TASK-037-11: Testy (unit + integration + negative)

**Cel:** Zgodnosc z `docs/TESTING_GUIDE`.

**Unit tests (tftest.hcl):**
- walidacje nazw (namespace, event hub).
- `auto_inflate_enabled` -> wymagany `maximum_throughput_units`.
- CMK wymaga user-assigned identity.
- `capture.enabled` -> wymagany storage account + container.
- `namespace_id` XOR `namespace_name` + `resource_group_name`.

**Integration / Terratest:**
- Fixtures:
  - Namespace: `basic`, `complete`, `secure`, `network-rule-set`
  - Event Hub: `basic`, `complete`, `secure`, `capture`, `consumer-groups`
- Weryfikacja:
  - namespace properties (sku/capacity/auto-inflate)
  - network rule set + auth rules
  - event hub properties (partition/retention/capture)
  - consumer groups + authorization rules

**Negatywne:**
- brak `maximum_throughput_units` przy auto-inflate
- `capture.enabled = true` bez storage account
- brak namespace inputow

---

### TASK-037-12: Automatyzacja i release

**Cel:** Spojna automatyzacja i dokumentacja.

**Do zrobienia:**
- `tests/Makefile`, `test_env.sh`, `run_tests_*` jak w AKS.
- `generate-docs.sh` zgodny z guide.
- Aktualizacja `docs/_TASKS/README.md` po wdrozeniu.
- Wpisy w `docs/_CHANGELOG/` dla nowych modulow.

---

## Acceptance Criteria

- Moduly `azurerm_eventhub_namespace` i `azurerm_eventhub` spelniaja layout z MODULE_GUIDE.
- Pokrycie wszystkich funkcji z feature matrix + potwierdzonych w provider schema.
- README/SECURITY/IMPORT/CONTRIBUTING/VERSIONING kompletne i spojne.
- Examples basic/complete/secure + feature-specific gotowe i uruchamialne.
- Testy unit + integration + negative przechodza lokalnie.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md` (status + statystyki)
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-eventhub-namespace.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-eventhub.md`
- `modules/README.md` (nowe moduly w tabeli AzureRM)
- `README.md` (badges + tabela "Available Modules")
