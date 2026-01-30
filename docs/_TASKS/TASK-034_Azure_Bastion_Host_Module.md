# TASK-034: Azure Bastion Host module (full feature scope)
# FileName: TASK-034_Azure_Bastion_Host_Module.md

**Priority:** High  
**Category:** New Module / Networking  
**Estimated Effort:** Medium  
**Dependencies:** -  
**Status:** Planned

---

## Cel

Stworzyc nowy modul `modules/azurerm_bastion_host` zgodny z:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

Modul ma pokrywac wszystkie funkcje dostepne w `azurerm_bastion_host`
oraz powiazane ustawienia diagnostyczne. AKS jest wzorcem struktury i testow;
wszystkie odstepstwa musza byc jawnie udokumentowane.

---

## Zakres (Provider Resources)

**Primary:**
- `azurerm_bastion_host`

**Powiazane zasoby (w module):**
- `azurerm_monitor_diagnostic_setting`

**Potwierdzone w providerze (azurerm 4.57.0, do potwierdzenia w TASK-034-1):**
- `azurerm_bastion_host`
- `azurerm_monitor_diagnostic_setting`

---

## Zalozenia i decyzje

1) **Atomic scope**  
   Modul zarzadza jednym Bastion Host jako primary resource. Dodatkowe zasoby
   tylko wtedy, gdy sa bezposrednio powiazane z Bastion (diagnostic settings).

2) **Brak cross-resource glue**  
   Poza modulem: VNet/subnet `AzureBastionSubnet`, public IP, NSG/UDR,
   Private DNS, RBAC/role assignments, Log Analytics workspace itd.
   Pokazujemy je tylko w examples jako osobne zasoby.

3) **Security-first**  
   Secure defaults gdzie to mozliwe (wylaczone opcje zdalne, brak nadmiarowych
   uprawnien). Wszystkie ryzyka opisane w `SECURITY.md`.

4) **Spojny styl**  
   Walidacje w `variables.tf`, zaleznosci cross-field jako `lifecycle`
   preconditions w `main.tf`.

---

## Feature matrix (musi byc pokryty)

- SKU (`Basic` / `Standard`)
- Scale units (Standard only)
- IP configuration (subnet + public IP)
- Copy/Paste
- File copy
- IP connect
- Shareable link
- Tunneling
- Session recording (jesli wspierane)
- Tags i timeouts
- Diagnostic settings (log/metric categories)

---

## Zakres i deliverables

### TASK-034-1: Discovery / feature inventory

**Cel:** Potwierdzic pelny zakres funkcji provider `azurerm` dla Bastion Host.

**Do zrobienia:**
- Sprawdzic schema provider `azurerm` (doc lub `terraform providers schema -json`)
  dla `azurerm_bastion_host`.
- Potwierdzic dokladne nazwy pol (copy/paste, file copy, ip connect, tunneling,
  shareable link, session recording) oraz powiazania z `sku`.
- Potwierdzic czy `ip_configuration` jest single-block czy lista oraz wymagane
  pola (`subnet_id`, `public_ip_address_id`).
- Spisac finalny zestaw pol i ograniczen (allowed values, required combos).
- Zaktualizowac listy walidacji, preconditions i examples na bazie realnych pol.

---

### TASK-034-2: Scaffold modulu + pliki bazowe

**Cel:** Stworzyc pelna strukture modulu zgodna z guide.

**Checklist:**
- [ ] `modules/azurerm_bastion_host/` utworzony przez
      `scripts/create-new-module.sh` (wymagane).
- [ ] `module.json`:
  - name: `azurerm_bastion_host`
  - commit_scope: `bastion-host`
  - tag_prefix: `BASTIONv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] `.releaserc.js`, `.terraform-docs.yml`, `Makefile`, `generate-docs.sh`
      zgodne z AKS.
- [ ] Pliki bazowe: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`,
      `VERSIONING.md`, `SECURITY.md`, `docs/IMPORT.md`.

---

### TASK-034-3: Core resource `azurerm_bastion_host`

**Cel:** Implementacja pelnego API Bastion Host w `main.tf` + walidacje w `variables.tf`.

**Zakres (przykladowy podzial inputow):**
- **core**: `name`, `resource_group_name`, `location`, `tags`
- **sku**: `sku`, `scale_units`
- **ip_configuration**: object/list (name, subnet_id, public_ip_address_id)
- **features**: `copy_paste_enabled`, `file_copy_enabled`, `ip_connect_enabled`,
  `shareable_link_enabled`, `tunneling_enabled`, `session_recording_enabled`
- **timeouts** (optional)

**Walidacje i preconditions (must-have):**
- Nazwa Bastion Host zgodna z rules Azure (length + regex).
- `sku` w dozwolonym zbiorze.
- `scale_units` tylko dla `Standard` + zakres zgodny z providerem.
- `ip_configuration`:
  - wymagany `subnet_id` i `public_ip_address_id`.
  - subnet musi wskazywac `AzureBastionSubnet` (walidacja po nazwie w ID).
  - jesli lista: max 1 element + unikalnosc `name`.
- `file_copy_enabled`, `ip_connect_enabled`, `shareable_link_enabled`,
  `tunneling_enabled`, `session_recording_enabled` tylko dla `Standard`.
- `copy_paste_enabled` w dozwolonym zakresie (wg provider schema).

**Implementation notes:**
- `locals` dla flag i map wynikowych.
- `lifecycle` preconditions dla regul cross-field.
- Nazwy zasobow i iteratorow zgodne z guide (no `this`, no skroty).

---

### TASK-034-4: Diagnostic settings (inline, AKS pattern)

**Cel:** Wbudowane `azurerm_monitor_diagnostic_setting` dla Bastion Host.

**Do zrobienia:**
- `diagnostic_settings` input (lista obiektow) jak w AKS.
- `data.azurerm_monitor_diagnostic_categories` + filtracja kategorii.
- `areas` -> mapowanie na log/metric categories (lub default `all`).
- `diagnostic_settings_skipped` output jak w AKS.

---

### TASK-034-5: Dokumentacja modulu

**Cel:** Kompletne docs zgodne z MODULE_GUIDE.

**Do zrobienia:**
- `README.md` z wymaganymi markerami i sekcjami (Module Documentation,
  Security Considerations).
- `docs/README.md`:
  - Overview, Managed Resources, Usage Notes
  - Out-of-scope zasoby (VNet/subnet, public IP, NSG/UDR, RBAC, LAW)
- `docs/IMPORT.md` wg AKS (import blocks + ID collection).
- `SECURITY.md`:
  - wymagany `AzureBastionSubnet`
  - public IP + ekspozycja
  - feature toggles (ip_connect/tunneling/shareable link)
- `CONTRIBUTING.md` i `VERSIONING.md` zgodne z `module.json`.

---

### TASK-034-6: Examples (basic/complete/secure + feature-specific)

**Cel:** Przyklady zgodne z guide, uruchamialne lokalnie.

**Wymagane:**
- `examples/basic`: minimalny Bastion (Basic SKU) + VNet + `AzureBastionSubnet` + public IP.
- `examples/complete`: Standard SKU + scale_units + feature toggles + diag settings.
- `examples/secure`: Standard SKU, wszystkie opcje zdalne wylaczone + NSG/UDR
  na `AzureBastionSubnet` (jezeli wspierane) + public access jawnie opisany w README.

**Feature-specific (propozycje):**
- `examples/ip-connect`
- `examples/tunneling`
- `examples/shareable-link`
- `examples/file-copy`
- `examples/diagnostic-settings`

**Wymagania wspolne:**
- `source = "../.."`, stale nazwy, `README.md` + `.terraform-docs.yml`.
- Zasoby pomocnicze (VNet, subnet, public IP, NSG) tworzone lokalnie w example.

---

### TASK-034-7: Testy (unit + integration + negative)

**Cel:** Zgodnosc z `docs/TESTING_GUIDE`.

**Unit tests (tftest.hcl):**
- walidacje nazw i zakresow (`sku`, `scale_units`).
- `AzureBastionSubnet` requirement (subnet name w ID).
- `Standard` tylko dla `file_copy/ip_connect/shareable_link/tunneling/session_recording`.
- `ip_configuration` (max 1 element + wymagane pola).

**Integration / Terratest:**
- fixtures: `basic`, `complete`, `secure`, `ip-connect`, `tunneling`,
  `shareable-link`, `diagnostic-settings`.
- weryfikacja:
  - state Bastion Host (sku, scale_units, feature toggles)
  - ip_configuration (subnet + public IP)
  - diag settings (log/metric categories)
- uwzglednic czas propagacji Bastion (retry/backoff).

**Negatywne:**
- `sku = Basic` + wlaczone funkcje Standard.
- brak `public_ip_address_id` lub zly subnet name.
- `scale_units` poza zakresem.

---

### TASK-034-8: Automatyzacja i release

**Cel:** Spojna automatyzacja i dokumentacja.

**Do zrobienia:**
- `tests/Makefile`, `test_env.sh`, `run_tests_*` jak w AKS.
- `generate-docs.sh` zgodny z guide.
- Aktualizacja `docs/_TASKS/README.md` po wdrozeniu.
- Wpis w `docs/_CHANGELOG/` dla nowego modulu.

---

## Acceptance Criteria

- Modul `modules/azurerm_bastion_host` spelnia layout z MODULE_GUIDE.
- Pokrycie wszystkich funkcji z feature matrix + potwierdzonych w provider schema.
- README/SECURITY/IMPORT/CONTRIBUTING/VERSIONING kompletne i spojne.
- Examples basic/complete/secure + feature-specific gotowe i uruchamialne.
- Testy unit + integration + negative przechodza lokalnie.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md` (status + statystyki)
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-azure-bastion-host.md`
- `modules/README.md` (nowy modul w tabeli AzureRM)
- `README.md` (badges + tabela "Available Modules")
