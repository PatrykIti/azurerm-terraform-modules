# TASK-035: Azure Cognitive Account module (OpenAI/Language/Speech)
# FileName: TASK-035_Cognitive_Account_Module.md

**Priority:** High  
**Category:** New Module / AI Services  
**Estimated Effort:** Large  
**Dependencies:** -  
**Status:** Done

---

## Cel

Stworzyc nowy modul dla `azurerm_cognitive_account` obejmujacy uslugi:
OpenAI, Language oraz Speech (wszystkie realizowane przez `azurerm_cognitive_account`).

Modul musi byc zgodny z:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

`azurerm_ai_services` jest poza zakresem tego taska i ma osobny
zadany task (TASK-040).

AKS jest wzorcem struktury i testow; wszystkie odstepstwa musza byc jawnie
udokumentowane.

---

## Zakres (Provider Resources)

**Primary (do potwierdzenia w 4.57.0):**
- `azurerm_cognitive_account` z `kind` dla OpenAI / Language / Speech

**Powiazane zasoby (w module, jesli wspierane):**
- `azurerm_cognitive_deployment` (OpenAI deployments)
- `azurerm_cognitive_account_rai_policy` (OpenAI RAI policy)
- `azurerm_cognitive_account_rai_blocklist` (OpenAI RAI blocklist)
- `azurerm_cognitive_account_customer_managed_key` (jesli osobny resource)
- `azurerm_monitor_diagnostic_setting`

**Opcjonalne (do potwierdzenia w providerze):**
- `azurerm_cognitive_account_rai_blocklist_item` (jesli istnieje)

**Out-of-scope:**
- `azurerm_ai_services` (osobny task `TASK-040`)
- Private endpoints, Private DNS Zone i VNet links
- RBAC/role assignments, policy, budzety
- Key Vault / Managed HSM / UAI provisioning (tylko ID inputy)
- Networking glue (subnety, NSG, UDR) i Log Analytics workspace

---

## Zalozenia i decyzje

1) **Atomic scope**  
   Modul zarzadza jednym Cognitive Account jako primary resource. Dodatkowe
   zasoby tylko te bezposrednio zwiazane z tym resource.
   OpenAI sub-resources (deployments, RAI) tworzone tylko dla `kind = OpenAI`.

2) **Brak cross-resource glue**  
   Private endpointy, DNS, RBAC i zasoby pomocnicze poza modulem.

3) **Security-first**  
   Secure defaults gdzie to mozliwe (np. wylaczenie local auth, private access
   przez inputy). Ryzyka opisane w `SECURITY.md`.

4) **Spojny styl**  
   Listy obiektow + `for_each` po `name`, walidacje w `variables.tf`, zaleznosci
   cross-field jako `lifecycle` preconditions w `main.tf`.

---

## Zaleznosci zasobu (poza modulem)

- **User Assigned Identity**: wymagane przy CMK.
- **Key Vault + Key**: dla `customer_managed_key`.
- **Private Endpoint + Private DNS Zone**: dla scenariuszy private access.
- **VNet/Subnet**: dla network ACLs i private endpoint.
- **Log Analytics / Storage / Event Hub**: cele dla diagnostic settings.

---

## Feature matrix (musi byc pokryty)

**Cognitive Account (common):**
- core: `name`, `resource_group_name`, `location`, `tags`
- `kind` (OpenAI / TextAnalytics / Language / SpeechServices / Speech)
- `sku_name` + dozwolone kombinacje `kind`/`sku`
- `custom_subdomain_name` (gdy wymagane przez network rules)
- `public_network_access_enabled` / `public_network_access` (wg schema)
- `local_authentication_enabled` / `local_auth_enabled`
- `network_acls` (ip_rules, virtual_network_rules, default_action, bypass)
- `outbound_network_access_restricted` (jesli wspierane)
- `fqdns` / allowlist FQDN (jesli wspierane)
- `identity` (SystemAssigned/UserAssigned)
- `customer_managed_key` (Key Vault / Managed HSM)
- `storage` block (jesli wspierany przez provider)
- `api_properties` (Speech, jesli wspierane)
- `timeouts`

**OpenAI-only:**
- deployments (`azurerm_cognitive_deployment`)
- RAI policy / blocklists

**Language-only:**
- `kind` = TextAnalytics/Language + ograniczenia `sku_name`

**Speech-only:**
- `kind` = SpeechServices/Speech + `api_properties` (jesli wspierane)

**Diagnostics:**
- `azurerm_monitor_diagnostic_setting` (logs + metrics + destination)

---

## Zakres i deliverables

### TASK-035-1: Discovery / feature inventory

**Cel:** Potwierdzic pelny zakres funkcji provider `azurerm` dla `azurerm_cognitive_account`.

**Do zrobienia:**
- Sprawdzic schema provider `azurerm` (docs lub `terraform providers schema -json`).
- Potwierdzic wspierane `kind` dla OpenAI/Language/Speech i ich `sku_name`.
- Potwierdzic pola sieciowe (`public_network_access*`, `network_acls`, `custom_subdomain_name`).
- Potwierdzic zasady `local_authentication_enabled` oraz `outbound_network_access_restricted`.
- Potwierdzic wymagania CMK (`customer_managed_key` + identity) i czy CMK jest inline czy osobnym resource.
- Potwierdzic, czy `storage` block jest wspierany i kiedy wymagany.
- Potwierdzic wsparcie OpenAI sub-resources (deployments/RAI) i ograniczenia.
- Spisac finalny zestaw pol i ograniczen (allowed values, required combos).
- Zaktualizowac walidacje, preconditions i examples na bazie realnych pol.

---

### TASK-035-2: Scaffold modulu + pliki bazowe

**Cel:** Stworzyc pelna strukture modulu zgodna z guide.

**Checklist:**
- [ ] `modules/azurerm_cognitive_account/` utworzony przez
      `scripts/create-new-module.sh` (wymagane).
- [ ] `module.json`:
  - name: `azurerm_cognitive_account`
  - commit_scope: `cognitive-account`
  - tag_prefix: `COGv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] `.releaserc.js`, `.terraform-docs.yml`, `Makefile`, `generate-docs.sh`
      zgodne z AKS.
- [ ] Pliki bazowe: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`,
      `VERSIONING.md`, `SECURITY.md`, `docs/IMPORT.md`.

---

### TASK-035-3: Core resource (Cognitive Account)

**Cel:** Implementacja pelnego API w `main.tf` + walidacje w `variables.tf`.

**Zakres (przykladowy podzial inputow):**
- **core**: `name`, `resource_group_name`, `location`, `tags`
- **sku**: `sku_name`
- **kind**: `kind` (OpenAI/Language/Speech)
- **network**: `public_network_access_*`, `network_acls`, `custom_subdomain_name`
- **auth**: `local_authentication_enabled`
- **identity**: `type`, `identity_ids`
- **cmk**: `customer_managed_key` (key id + identity_client_id)
- **outbound**: `outbound_network_access_restricted`
- **fqdns**: allowlist (jesli wspierane)
- **storage**: `storage` block (jesli wspierane)
- **api_properties**: (Speech, jesli wspierane)
- **timeouts** (optional)

**Walidacje i preconditions (must-have):**
- Nazwa zasobu zgodna z Azure rules (length + regex).
- `kind` ograniczony do dozwolonych wartosci (OpenAI/Language/Speech).
- `sku_name` w dozwolonych wartosciach dla wybranego `kind`.
- `custom_subdomain_name` wymagany, gdy provider tego wymaga (np. przy network rules).
- `network_acls.default_action` w dozwolonych wartosciach.
- `customer_managed_key` wymaga `identity` z user-assigned.
- `identity_ids` wymagane, gdy `type` zawiera `UserAssigned`.
- `local_authentication_enabled = false` -> brak outputs z kluczami (jesli wystepuja).

**Implementation notes:**
- `locals` dla flag i map wynikowych.
- `lifecycle` preconditions dla regul cross-field.
- Nazwy zasobow i iteratorow zgodne z guide (no `this`, no skroty).

---

### TASK-035-4: Sub-resources (OpenAI deployments, RAI, CMK)

**Cel:** Pelne wsparcie sub-resources zwiazanych z Cognitive Account.

**Inputs (propozycja):**
- `deployments`: list(object({
    name,
    model = object({ format, name, version }),
    sku = optional(object({ name, capacity })),
    scale = optional(object({ type, capacity })),
    rai_policy_name = optional(string)
  }))
- `rai_policies`: list(object({
    name,
    base_policy_name,
    content_filters = list(object({ name, filter_enabled, block_enabled, severity_threshold, source }))
  }))
- `rai_blocklists`: list(object({ name, description }))
- `rai_blocklist_items`: list(object({ blocklist_name, name, pattern })) (jesli wspierane)
- `customer_managed_key` (jesli CMK jest osobnym resource)

**Wymagania:**
- `for_each` po `name` + walidacja unikalnosci.
- Walidacje zakresow (model format, sku/scale, severity_threshold).
- OpenAI sub-resources tylko dla `kind = OpenAI`.
- `rai_blocklist_items` wymagaja istniejacego blocklist.
- CMK wymaga user-assigned identity.

---

### TASK-035-5: Diagnostic settings (inline, AKS pattern)

**Cel:** Wbudowane `azurerm_monitor_diagnostic_setting` dla Cognitive Account.

**Do zrobienia:**
- `diagnostic_settings` input (lista obiektow) jak w AKS.
- `data.azurerm_monitor_diagnostic_categories` + filtracja kategorii.
- `areas` -> mapowanie na log/metric categories (lub default `all`).
- `diagnostic_settings_skipped` output jak w AKS.

---

### TASK-035-6: Dokumentacja modulu

**Cel:** Kompletne docs zgodne z MODULE_GUIDE.

**Do zrobienia:**
- `README.md` z wymaganymi markerami i sekcjami (Module Documentation, Security Considerations).
- `docs/README.md`:
  - Overview, Managed Resources, Usage Notes
  - Out-of-scope zasoby (private endpoints, RBAC, Key Vault)
- `docs/IMPORT.md` wg AKS (import blocks + ID collection).
- `SECURITY.md`:
  - posture (public access, local auth, CMK, network rules)
  - secure example
  - checklist i typowe bledy
- `CONTRIBUTING.md` i `VERSIONING.md` zgodne z `module.json`.

---

### TASK-035-7: Examples (basic/complete/secure + feature-specific)

**Cel:** Przyklady zgodne z guide, uruchamialne lokalnie.

**Wymagane:**
- `examples/basic`: minimalny account (OpenAI) z public access.
- `examples/complete`: OpenAI + network_acls + identity + diagnostics + tags.
- `examples/secure`: OpenAI + local auth off + CMK + UAI + public access disabled + private endpoint (poza modulem).

**Feature-specific (propozycje):**
- `examples/openai-deployments`
- `examples/openai-rai-policy`
- `examples/language-service`
- `examples/speech-service`
- `examples/customer-managed-key`
- `examples/private-endpoint` (z osobnym `azurerm_private_endpoint` i DNS)

**Wymagania wspolne:**
- `source = "../.."`, stale nazwy, `README.md` + `.terraform-docs.yml`.
- Zasoby pomocnicze (VNet, subnet, Key Vault, UAI) tworzone lokalnie w example.

---

### TASK-035-8: Testy (unit + integration + negative)

**Cel:** Zgodnosc z `docs/TESTING_GUIDE`.

**Unit tests (tftest.hcl):**
- walidacje `kind` i `sku_name`.
- reguly `custom_subdomain_name` (jesli wymagane przez provider).
- reguly `customer_managed_key` + identity.
- walidacje network ACLs (default_action, ip_rules format).
- OpenAI sub-resources wymagaja `kind = OpenAI`.

**Integration / Terratest:**
- fixtures: `openai-basic`, `openai-complete`, `openai-secure`, `language-basic`, `speech-basic`.
- weryfikacja:
  - account properties (kind, sku, network, identity)
  - CMK (jesli enabled)
  - diagnostic settings (log/metric categories)
  - deployments/RAI tylko dla OpenAI

**Negatywne:**
- CMK bez user-assigned identity.
- `kind` spoza dozwolonego zbioru.
- invalid `network_acls.default_action`.

---

### TASK-035-9: Automatyzacja i release

**Cel:** Spojna automatyzacja i dokumentacja.

**Do zrobienia:**
- `tests/Makefile`, `test_env.sh`, `run_tests_*` jak w AKS.
- `generate-docs.sh` zgodny z guide.
- Aktualizacja `docs/_TASKS/README.md` po wdrozeniu.
- Wpis w `docs/_CHANGELOG/` dla nowego modulu.

---

## Acceptance Criteria

- Modul `modules/azurerm_cognitive_account` spelnia layout z MODULE_GUIDE.
- Pokrycie wszystkich funkcji z feature matrix + potwierdzonych w provider schema.
- README/SECURITY/IMPORT/CONTRIBUTING/VERSIONING kompletne i spojne.
- Examples basic/complete/secure + feature-specific gotowe i uruchamialne.
- Testy unit + integration + negative przechodza lokalnie.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md` (status + statystyki)
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-cognitive-account.md`
- `modules/README.md` (nowy modul w tabeli AzureRM)
- `README.md` (badges + tabela "Available Modules")
