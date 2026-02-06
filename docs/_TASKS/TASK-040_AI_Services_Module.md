# TASK-040: Azure AI Services module (azurerm_ai_services)
# FileName: TASK-040_AI_Services_Module.md

**Priority:** High  
**Category:** New Module / AI Services  
**Estimated Effort:** Large  
**Dependencies:** -  
**Status:** Done

---

## Cel

Stworzyc nowy modul dla `azurerm_ai_services` zgodny z:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

Ten task dotyczy wylacznie resource typu `azurerm_ai_services`.
Istniejace zasoby oparte o `azurerm_cognitive_account` sa poza zakresem
(osobny task `TASK-035`). Jesli provider mapuje OpenAI/Language/Speech
na `azurerm_ai_services`, to ich wsparcie jest w tym module
i musi byc potwierdzone w discovery.

AKS jest wzorcem struktury i testow; wszystkie odstepstwa musza byc jawnie
udokumentowane.

---

## Zakres (Provider Resources)

**Primary (do potwierdzenia w 4.57.0):**
- `azurerm_ai_services`

**Powiazane zasoby (w module, jesli wspierane):**
- Deploymenty / modele (resource name do potwierdzenia w discovery)
- Polityki i blocklisty RAI (jesli wspierane przez `azurerm` dla AI Services)
- `azurerm_monitor_diagnostic_setting`

**Out-of-scope:**
- `azurerm_cognitive_account` (osobny task `TASK-035`)
- Private endpoints, Private DNS Zone i VNet links
- RBAC/role assignments, policy, budzety
- Key Vault / Managed HSM / UAI provisioning (tylko ID inputy)
- Networking glue (subnety, NSG, UDR) i Log Analytics workspace

---

## Zalozenia i decyzje

1) **Atomic scope**  
   Modul zarzadza jednym AI Services Account jako primary resource. Dodatkowe
   zasoby tylko te bezposrednio zwiazane z tym resource (np. deployments, RAI).

2) **Brak cross-resource glue**  
   Private endpointy, DNS, RBAC i zasoby pomocnicze poza modulem.

3) **Security-first**  
   Secure defaults gdzie to mozliwe (np. wylaczenie local auth, ograniczenia
   sieci). Ryzyka opisane w `SECURITY.md`.

4) **Spojny styl**  
   Listy obiektow + `for_each` po `name`, walidacje w `variables.tf`, zaleznosci
   cross-field jako `lifecycle` preconditions w `main.tf`.

---

## Feature matrix (musi byc pokryty)

**AI Services account:**
- core: `name`, `resource_group_name`, `location`, `tags`
- `kind` / `sku_name` / `custom_subdomain_name` (wg schema; OpenAI/Language/Speech jesli wspierane)
- `public_network_access_enabled` / `public_network_access`
- `local_authentication_enabled` / `local_auth_enabled`
- `network_acls` (ip_rules, virtual_network_rules, default_action, bypass)
- `outbound_network_access_restricted` (jesli wspierane)
- `identity` (SystemAssigned/UserAssigned)
- `customer_managed_key` (Key Vault / Managed HSM)
- `storage` block (jesli wspierane)
- `timeouts`

**Deployments / RAI (jesli wspierane):**
- deployment model + sku/scale (wg provider schema)
- RAI policy / blocklist (wg provider schema)

**Diagnostics:**
- `azurerm_monitor_diagnostic_setting` (logs + metrics + destination)

---

## Zakres i deliverables

### TASK-040-1: Discovery / feature inventory

**Cel:** Potwierdzic pelny zakres funkcji provider `azurerm` dla `azurerm_ai_services`.

**Do zrobienia:**
- Sprawdzic schema provider `azurerm` (docs lub `terraform providers schema -json`).
- Potwierdzic wspierane `kind` (OpenAI/Language/Speech lub inne) i ich `sku_name`.
- Potwierdzic nazwy i wsparcie sub-resources (deployments/RAI) dla AI Services.
- Spisac finalny zestaw pol, ograniczen i wymaganych kombinacji.
- Zaktualizowac walidacje, preconditions i examples na bazie realnych pol.

---

### TASK-040-2: Scaffold modulu + pliki bazowe

**Cel:** Stworzyc pelna strukture modulu zgodna z guide.

**Checklist:**
- [ ] `modules/azurerm_ai_services/` utworzony przez
      `scripts/create-new-module.sh` (wymagane).
- [ ] `module.json`:
  - name: `azurerm_ai_services`
  - commit_scope: `ai-services-account`
  - tag_prefix: `AISv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] `.releaserc.js`, `.terraform-docs.yml`, `Makefile`, `generate-docs.sh`
      zgodne z AKS.
- [ ] Pliki bazowe: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`,
      `VERSIONING.md`, `SECURITY.md`, `docs/IMPORT.md`.

---

### TASK-040-3: Core resource `azurerm_ai_services`

**Cel:** Implementacja pelnego API w `main.tf` + walidacje w `variables.tf`.

**Zakres (przykladowy podzial inputow):**
- **core**: `name`, `resource_group_name`, `location`, `tags`
- **sku/kind**: `sku_name`, `kind` (wg schema)
- **network**: `public_network_access_*`, `network_acls`, `custom_subdomain_name`
- **auth**: `local_authentication_enabled`
- **identity**: `type`, `identity_ids`
- **cmk**: `customer_managed_key` (key id + identity_client_id)
- **outbound**: `outbound_network_access_restricted`
- **storage**: `storage` block (jesli wspierane)
- **timeouts** (optional)

**Walidacje i preconditions (must-have):**
- Nazwa zasobu zgodna z Azure rules (length + regex).
- Dozwolone wartosci `sku_name` i `kind` (wg provider).
- `custom_subdomain_name` wymagany gdy `network_acls` ustawione (jesli dotyczy).
- `customer_managed_key` wymaga `identity` z user-assigned.
- `identity_ids` wymagane gdy `type` zawiera `UserAssigned`.

---

### TASK-040-4: Sub-resources (deployments, RAI, itd.)

**Cel:** Pelne wsparcie sub-resources zwiazanych z AI Services Account (jesli wspierane).

**Inputs (propozycja, do weryfikacji):**
- `deployments`: list(object({ name, model, sku/scale, ... }))
- `rai_policies`: list(object({ name, base_policy_name, content_filters = list(object(...)) }))
- `rai_blocklists`: list(object({ name, description }))

**Wymagania:**
- `for_each` po `name` + walidacja unikalnosci.
- Walidacje zakresow (model/sku/scale/severity).

---

### TASK-040-5: Diagnostic settings (inline, AKS pattern)

**Cel:** Wbudowane `azurerm_monitor_diagnostic_setting` dla AI Services Account.

**Do zrobienia:**
- `diagnostic_settings` input (lista obiektow) jak w AKS.
- `data.azurerm_monitor_diagnostic_categories` + filtracja kategorii.
- `areas` -> mapowanie na log/metric categories (lub default `all`).
- `diagnostic_settings_skipped` output jak w AKS.

---

### TASK-040-6: Dokumentacja modulu

**Cel:** Kompletne docs zgodne z MODULE_GUIDE.

**Do zrobienia:**
- `README.md` z wymaganymi markerami i sekcjami (Module Documentation, Security Considerations).
- `docs/README.md`:
  - Overview, Managed Resources, Usage Notes
  - Out-of-scope zasoby (private endpoints, RBAC, Key Vault)
- `docs/IMPORT.md` wg AKS (import blocks + ID collection).
- `SECURITY.md`:
  - posture (private access, local auth, CMK, network ACLs)
  - secure example
  - checklist i typowe bledy
- `CONTRIBUTING.md` i `VERSIONING.md` zgodne z `module.json`.

---

### TASK-040-7: Examples (basic/complete/secure + feature-specific)

**Cel:** Przyklady zgodne z guide, uruchamialne lokalnie.

**Wymagane:**
- `examples/basic`: minimal account.
- `examples/complete`: network ACLs + custom subdomain + diag settings + deployments (jesli wspierane).
- `examples/secure`: local auth off + CMK + UAI + public access disabled + private endpoint (poza modulem).

**Feature-specific (propozycje):**
- `examples/deployments` (jesli wspierane)
- `examples/rai-policy` (jesli wspierane)
- `examples/language-service` (jesli wspierane)
- `examples/speech-service` (jesli wspierane)

---

### TASK-040-8: Testy (unit + integration + negative)

**Cel:** Zgodnosc z `docs/TESTING_GUIDE`.

**Unit tests (tftest.hcl):**
- walidacje nazw i dozwolonych values.
- `customer_managed_key` wymaga user-assigned identity.
- `custom_subdomain_name` przy `network_acls`.

**Integration / Terratest:**
- fixtures: `basic`, `complete`, `secure`, `deployments` (jesli wspierane),
  `language` (jesli wspierane), `speech` (jesli wspierane).
- weryfikacja: properties accountu, network rules, identity, diagnostics.

**Negatywne:**
- brak wymaganych pol dla CMK
- niepoprawne `kind`/`sku_name`

---

### TASK-040-9: Automatyzacja i release

**Cel:** Spojna automatyzacja i dokumentacja.

**Do zrobienia:**
- `tests/Makefile`, `test_env.sh`, `run_tests_*` jak w AKS.
- `generate-docs.sh` zgodny z guide.
- Aktualizacja `docs/_TASKS/README.md` po wdrozeniu.
- Wpisy w `docs/_CHANGELOG/` dla nowego modulu.

---

## Acceptance Criteria

- Modul `azurerm_ai_services` spelnia layout z MODULE_GUIDE.
- Pokrycie wszystkich funkcji z feature matrix + potwierdzonych w provider schema.
- README/SECURITY/IMPORT/CONTRIBUTING/VERSIONING kompletne i spojne.
- Examples basic/complete/secure + feature-specific gotowe i uruchamialne.
- Testy unit + integration + negative przechodza lokalnie.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md` (status + statystyki)
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ai-services-account.md`
- `modules/README.md` (nowy modul w tabeli AzureRM)
- `README.md` (badges + tabela "Available Modules")
