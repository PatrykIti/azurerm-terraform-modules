# TASK-029: Key Vault module (full feature scope)
# FileName: TASK-029_Key_Vault_Module.md

**Priority:** High  
**Category:** New Module / Security  
**Estimated Effort:** Large  
**Dependencies:** -  
**Status:** Planned

---

## Cel

Stworzyc nowy modul `modules/azurerm_key_vault` zgodny z:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

Modul ma pokrywac wszystkie funkcje dostepne w `azurerm_key_vault`
oraz sub-resources powiazane z Key Vault (dane i konfiguracje). AKS jest
wzorcem struktury i testow; wszystkie odstepstwa musza byc jawnie udokumentowane.

---

## Zakres (Provider Resources)

**Primary:**
- `azurerm_key_vault`

**Powiazane zasoby (w module):**
- `azurerm_key_vault_access_policy`
- `azurerm_key_vault_key`
- `azurerm_key_vault_secret`
- `azurerm_key_vault_certificate`
- `azurerm_key_vault_certificate_issuer`
- `azurerm_key_vault_managed_storage_account`
- `azurerm_key_vault_managed_storage_account_sas_token_definition`
- `azurerm_monitor_diagnostic_setting`

**Potwierdzone w providerze (azurerm 4.57.0, do potwierdzenia w TASK-029-1):**
- `azurerm_key_vault`
- `azurerm_key_vault_access_policy`
- `azurerm_key_vault_key`
- `azurerm_key_vault_secret`
- `azurerm_key_vault_certificate`
- `azurerm_key_vault_certificate_issuer`
- `azurerm_key_vault_managed_storage_account`
- `azurerm_key_vault_managed_storage_account_sas_token_definition`

---

## Zalozenia i decyzje

1) **Atomic scope**  
   Modul zarzadza jednym Key Vault jako primary resource. Dodatkowe zasoby
   tylko wtedy, gdy sa bezposrednio powiazane z KV: access policies (gdy RBAC
   jest wylaczone), keys, secrets, certificates, issuer, managed storage,
   diagnostic settings.

2) **Brak cross-resource glue**  
   Poza modulem: private endpoints, Private DNS, RBAC/role assignments,
   VNet/subnety, Storage Accounty (samego konta), Log Analytics workspace itd.
   Pokazujemy je tylko w examples jako osobne zasoby.

3) **Security-first**  
   Secure defaults gdzie to mozliwe (soft-delete, purge protection, brak public
   access bez jawnego inputu). Wszystkie ryzyka opisane w `SECURITY.md`.

4) **Spojny styl**  
   Listy obiektow + `for_each` po `name`, walidacje w `variables.tf`, zaleznosci
   cross-field jako `lifecycle` preconditions w `main.tf`.

---

## Feature matrix (musi byc pokryty)

- SKU (`standard`/`premium`)
- tenant_id + podstawowe flagi (deployment/disk/template)
- soft delete retention + purge protection
- RBAC vs access policies (mutually exclusive)
- public network access toggle
- network ACLs (bypass, default_action, ip_rules, vnet_subnet_ids)
- keys (typ, rozmiar/curve, key opts, rotation policy)
- secrets (value, content_type, not_before/expiration)
- certificates (policy, issuer, lifetime actions)
- certificate issuer (opcjonalnie)
- managed storage account + SAS token definitions (opcjonalnie)
- diagnostic settings (log/metric categories)
- tags + timeouts

---

## Zakres i deliverables

### TASK-029-1: Discovery / feature inventory

**Cel:** Potwierdzic pelny zakres funkcji provider `azurerm` dla KV i sub-resources.

**Do zrobienia:**
- Sprawdzic schema provider `azurerm` (doc lub `terraform providers schema -json`)
  dla `azurerm_key_vault` i zasobow powiazanych.
- Potwierdzic dokladne nazwy oraz status wsparcia dla:
  - `azurerm_key_vault_certificate_issuer`
  - `azurerm_key_vault_managed_storage_account`
  - `azurerm_key_vault_managed_storage_account_sas_token_definition`
- Spisac finalny zestaw pol i ograniczen (allowed values, required combos).
- Zaktualizowac walidacje, preconditions i examples na bazie realnych pol.

---

### TASK-029-2: Scaffold modulu + pliki bazowe

**Cel:** Stworzyc pelna strukture modulu zgodna z guide.

**Checklist:**
- [ ] `modules/azurerm_key_vault/` utworzony przez
      `scripts/create-new-module.sh` (wymagane).
- [ ] `module.json`:
  - name: `azurerm_key_vault`
  - commit_scope: `key-vault`
  - tag_prefix: `KVv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] `.releaserc.js`, `.terraform-docs.yml`, `Makefile`, `generate-docs.sh`
      zgodne z AKS.
- [ ] Pliki bazowe: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`,
      `VERSIONING.md`, `SECURITY.md`, `docs/IMPORT.md`.

---

### TASK-029-3: Core resource `azurerm_key_vault`

**Cel:** Implementacja pelnego API KV w `main.tf` + walidacje w `variables.tf`.

**Zakres (przykladowy podzial inputow):**
- **core**: `name`, `resource_group_name`, `location`, `tags`
- **sku/tenant**: `sku_name`, `tenant_id`
- **flags**: `enabled_for_deployment`, `enabled_for_disk_encryption`,
  `enabled_for_template_deployment`
- **security**: `soft_delete_retention_days`, `purge_protection_enabled`,
  `enable_rbac_authorization`
- **network**: `public_network_access_enabled`, `network_acls`
- **contacts**: `contacts` (jesli wspierane w providerze)
- **timeouts** (optional)

**Walidacje i preconditions (must-have):**
- Nazwa KV zgodna z rules Azure (length + regex).
- `sku_name` w dozwolonym zbiorze.
- `soft_delete_retention_days` w zakresie (np. 7-90).
- `purge_protection_enabled = true` -> wymagany soft delete retention.
- `enable_rbac_authorization = true` -> brak access policies w module.
- `enable_rbac_authorization = false` -> `access_policies` dozwolone.
- `public_network_access_enabled = false` -> ostrzezenie w SECURITY.md o
  wymaganym Private Endpoint (walidacje tylko jesli schema tego wymaga).
- `network_acls.default_action` tylko `Allow`/`Deny`, `bypass` w dozwolonych
  wartosciach; walidacja `ip_rules` jako CIDR/IP.

**Implementation notes:**
- `locals` dla flag i map wynikowych.
- `lifecycle` preconditions dla regul cross-field.
- Nazwy zasobow i iteratorow zgodne z guide (no `this`, no skroty).

---

### TASK-029-4: Sub-resources (access policies, keys, secrets, certificates, managed storage)

**Cel:** Pelne wsparcie sub-resources zwiazanych z Key Vault.

**Inputs (propozycje):**
- `access_policies`: list(object({
    tenant_id, object_id, application_id?,
    key_permissions, secret_permissions, certificate_permissions, storage_permissions
  }))
- `keys`: list(object({
    name, key_type, key_size?, curve?, key_opts,
    not_before_date?, expiration_date?, tags?,
    rotation_policy?
  }))
- `secrets`: list(object({
    name, value, content_type?, not_before_date?, expiration_date?, tags?
  }))
- `certificates`: list(object({
    name, certificate_policy, certificate?, tags?
  }))
- `certificate_issuers`: list(object({
    name, provider_name, account_id?, password?, org_details?, administrators?
  }))
- `managed_storage_accounts`: list(object({
    name, storage_account_id, storage_account_key?, active_key_name,
    auto_regenerate_key?, regeneration_period?, tags?
  }))
- `managed_storage_sas_definitions`: list(object({
    name, managed_storage_account_name, sas_template, sas_type,
    validity_period, tags?
  }))

**Wymagania:**
- `for_each` po `name` + walidacja unikalnosci.
- RBAC mode -> blokada `access_policies`.
- `keys`: walidacje `key_type` + `key_size`/`curve` + `key_opts`.
- `rotation_policy` zgodnie z schema (expire/notify, lifetime actions).
- `secrets.value` jako `sensitive`, walidacja pustych wartosci.
- `certificates`: walidacje policy (issuer, key props, x509 props, actions).
- Managed storage: wymagany `storage_account_id` (konto poza modulem).

---

### TASK-029-5: Diagnostic settings (inline, AKS pattern)

**Cel:** Wbudowane `azurerm_monitor_diagnostic_setting` dla Key Vault.

**Do zrobienia:**
- `diagnostic_settings` input (lista obiektow) jak w AKS.
- `data.azurerm_monitor_diagnostic_categories` + filtracja kategorii.
- `areas` -> mapowanie na log/metric categories (lub default `all`).
- `diagnostic_settings_skipped` output jak w AKS.

---

### TASK-029-6: Dokumentacja modulu

**Cel:** Kompletne docs zgodne z MODULE_GUIDE.

**Do zrobienia:**
- `README.md` z wymaganymi markerami i sekcjami (Module Documentation,
  Security Considerations).
- `docs/README.md`:
  - Overview, Managed Resources, Usage Notes
  - Out-of-scope zasoby (private endpoints, RBAC role assignments, VNet/DNS)
- `docs/IMPORT.md` wg AKS (import blocks + ID collection).
- `SECURITY.md`:
  - soft delete/purge protection
  - public access vs private endpoint
  - RBAC vs access policies
  - rotacje i zarzadzanie sekretami/kluczami
- `CONTRIBUTING.md` i `VERSIONING.md` zgodne z `module.json`.

---

### TASK-029-7: Examples (basic/complete/secure + feature-specific)

**Cel:** Przyklady zgodne z guide, uruchamialne lokalnie.

**Wymagane:**
- `examples/basic`: public access, minimal config, jeden sekret.
- `examples/complete`: network ACLs + keys + secrets + certificates + diag settings.
- `examples/secure`: private endpoint + private DNS + public access disabled +
  purge protection + RBAC (role assignments poza modulem).

**Feature-specific (propozycje):**
- `examples/access-policies`
- `examples/rbac`
- `examples/keys`
- `examples/secrets`
- `examples/certificates`
- `examples/certificate-issuer`
- `examples/managed-storage-account`
- `examples/diagnostic-settings`
- `examples/rotation-policy`

**Wymagania wspolne:**
- `source = "../.."`, stale nazwy, `README.md` + `.terraform-docs.yml`.
- Zasoby pomocnicze (VNet, subnet, private DNS, storage account) tworzone
  lokalnie w example.

---

### TASK-029-8: Testy (unit + integration + negative)

**Cel:** Zgodnosc z `docs/TESTING_GUIDE`.

**Unit tests (tftest.hcl):**
- walidacje nazw i zakresow (sku, retention).
- RBAC vs access policies (mutual exclusivity).
- reguly `network_acls` + `public_network_access_enabled`.
- walidacje `keys` (key_type/size/curve) i `rotation_policy`.
- walidacje `certificates` policy.

**Integration / Terratest:**
- fixtures: `basic`, `complete`, `secure`, `keys`, `secrets`, `certificates`,
  `diagnostic-settings`, `managed-storage-account`.
- weryfikacja:
  - KV state (sku, network, soft delete, purge protection)
  - data-plane obiekty (keys/secrets/certs)
  - diag settings (log/metric categories)
- uwzglednic opoznienia propagacji access policies / RBAC (retry/backoff).

**Negatywne:**
- RBAC enabled + access_policies.
- niepoprawny `key_type` vs `key_size`/`curve`.
- `soft_delete_retention_days` poza zakresem.

---

### TASK-029-9: Automatyzacja i release

**Cel:** Spojna automatyzacja i dokumentacja.

**Do zrobienia:**
- `tests/Makefile`, `test_env.sh`, `run_tests_*` jak w AKS.
- `generate-docs.sh` zgodny z guide.
- Aktualizacja `docs/_TASKS/README.md` po wdrozeniu.
- Wpis w `docs/_CHANGELOG/` dla nowego modulu.

---

## Acceptance Criteria

- Modul `modules/azurerm_key_vault` spelnia layout z MODULE_GUIDE.
- Pokrycie wszystkich funkcji z feature matrix + potwierdzonych w provider schema.
- README/SECURITY/IMPORT/CONTRIBUTING/VERSIONING kompletne i spojne.
- Examples basic/complete/secure + feature-specific gotowe i uruchamialne.
- Testy unit + integration + negative przechodza lokalnie.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md` (status + statystyki)
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-key-vault.md`
- `modules/README.md` (nowy modul w tabeli AzureRM)
- `README.md` (badges + tabela "Available Modules")
