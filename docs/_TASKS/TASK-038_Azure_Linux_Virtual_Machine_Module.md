# TASK-038: Azure Linux Virtual Machine module (full feature scope)
# FileName: TASK-038_Azure_Linux_Virtual_Machine_Module.md

**Priority:** High  
**Category:** New Module / Compute  
**Estimated Effort:** Large  
**Dependencies:** -  
**Status:** Planned

---

## Cel

Stworzyc nowy modul `modules/azurerm_linux_virtual_machine` zgodny z:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

Modul ma pokrywac wszystkie funkcje dostepne w `azurerm_linux_virtual_machine`
oraz powiazane sub-resources bezposrednio zwiazane z VM (tylko te, ktore sa
VM-scope). AKS jest wzorcem struktury i testow; wszystkie odstepstwa musza byc
jawnie udokumentowane.

---

## Zakres (Provider Resources)

**Primary:**
- `azurerm_linux_virtual_machine`

**Powiazane zasoby (w module):**
- `azurerm_virtual_machine_extension`
- `azurerm_monitor_diagnostic_setting`

**Potwierdzone w providerze (azurerm 4.57.0, do potwierdzenia w TASK-038-1):**
- `azurerm_linux_virtual_machine`
- `azurerm_virtual_machine_extension`
- `azurerm_monitor_diagnostic_setting`

---

## Zalozenia i decyzje

1) **Atomic scope**  
   Modul zarzadza jednym Linux VM jako primary resource. Dodatkowe zasoby tylko
   wtedy, gdy sa bezposrednio powiazane z VM (extensions, diagnostic settings).

2) **Brak cross-resource glue**  
   Poza modulem: VNet/subnet, NSG, public IP, NIC, Private DNS, RBAC/role
   assignments, Recovery Services Vault/Backup, Key Vault/CMK management,
   Log Analytics workspace, monitoring glue. Pokazujemy je tylko w examples
   jako osobne zasoby.

3) **Security-first**  
   Secure defaults gdzie to mozliwe (SSH keys, brak hasla, brak public IP
   w secure example). Wszystkie ryzyka opisane w `SECURITY.md`.

4) **Spojny styl**  
   Listy obiektow + `for_each` po `name`, walidacje w `variables.tf`, zaleznosci
   cross-field jako `lifecycle` preconditions w `main.tf`.

---

## Feature matrix (musi byc pokryty)

- Core: name, resource_group_name, location, size, tags
- Network: `network_interface_ids` + primary NIC (jesli wspierane)
- Admin/auth: `admin_username`, `disable_password_authentication`,
  `admin_password`, `admin_ssh_key`
- Image: `source_image_reference` vs `source_image_id` (mutually exclusive)
- OS disk: name, caching, storage_account_type, disk_size_gb,
  write_accelerator_enabled, disk_encryption_set_id (jesli wspierane)
- Data disks (inline): lun, caching, disk_size_gb, storage_account_type,
  write_accelerator_enabled
- Boot diagnostics: enabled + storage_account_uri (lub managed)
- Identity: SystemAssigned / UserAssigned
- Availability: zone, availability_set_id, proximity_placement_group_id,
  dedicated_host_id / dedicated_host_group_id, capacity_reservation_group_id
- Security profile: secure_boot_enabled, vtpm_enabled, encryption_at_host_enabled
- Spot/priority: priority, eviction_policy, max_bid_price
- Additional capabilities: ultra_ssd_enabled (jesli wspierane)
- Agent/patching: provision_vm_agent, patch_mode, patch_assessment_mode
- Plan / purchase plan (marketplace images)
- Custom data / user data (cloud-init)
- Tags i timeouts
- VM extensions
- Diagnostic settings (log/metric categories)

---

## Zakres i deliverables

### TASK-038-1: Discovery / feature inventory

**Cel:** Potwierdzic pelny zakres funkcji provider `azurerm` dla Linux VM.

**Do zrobienia:**
- Sprawdzic schema provider `azurerm` (doc lub `terraform providers schema -json`)
  dla `azurerm_linux_virtual_machine`.
- Potwierdzic dokladne pola i zaleznosci dla:
  - admin/password/ssh keys
  - source image (reference vs id)
  - OS disk + data disks
  - availability/host settings
  - security profile + encryption_at_host
  - boot diagnostics + managed vs storage account
  - patching/agent fields
  - plan / marketplace images
- Potwierdzic resource schema dla `azurerm_virtual_machine_extension`.
- Spisac finalny zestaw pol i ograniczen (allowed values, required combos).
- Zaktualizowac listy walidacji, preconditions i examples na bazie realnych pol.

---

### TASK-038-2: Scaffold modulu + pliki bazowe

**Cel:** Stworzyc pelna strukture modulu zgodna z guide.

**Checklist:**
- [ ] `modules/azurerm_linux_virtual_machine/` utworzony przez
      `scripts/create-new-module.sh` (wymagane).
- [ ] `module.json`:
  - name: `azurerm_linux_virtual_machine`
  - commit_scope: `linux-virtual-machine`
  - tag_prefix: `LINUXVMv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] `.releaserc.js`, `.terraform-docs.yml`, `Makefile`, `generate-docs.sh`
      zgodne z AKS.
- [ ] Pliki bazowe: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`,
      `VERSIONING.md`, `SECURITY.md`, `docs/IMPORT.md`.

---

### TASK-038-3: Core resource `azurerm_linux_virtual_machine`

**Cel:** Implementacja pelnego API Linux VM w `main.tf` + walidacje w `variables.tf`.

**Zakres (przykladowy podzial inputow):**
- **core**: `name`, `resource_group_name`, `location`, `size`, `tags`
- **network**: `network_interface_ids`, `primary_network_interface_id`
- **admin**: `admin_username`, `disable_password_authentication`,
  `admin_password`, `admin_ssh_key` (list)
- **image**: `source_image_reference`, `source_image_id`, `plan`
- **os_disk**: object (name, caching, storage_account_type, disk_size_gb,
  write_accelerator_enabled, disk_encryption_set_id)
- **data_disks**: list(object({ name, lun, caching, disk_size_gb,
  storage_account_type, write_accelerator_enabled }))
- **boot_diagnostics**: object({ enabled, storage_account_uri })
- **identity**: object({ type, identity_ids })
- **availability**: `zone`, `availability_set_id`, `proximity_placement_group_id`,
  `dedicated_host_id`, `dedicated_host_group_id`, `capacity_reservation_group_id`
- **security_profile**: `secure_boot_enabled`, `vtpm_enabled`,
  `encryption_at_host_enabled`
- **spot**: `priority`, `eviction_policy`, `max_bid_price`
- **additional_capabilities**: `ultra_ssd_enabled`
- **agent/patching**: `provision_vm_agent`, `patch_mode`, `patch_assessment_mode`
- **custom_data/user_data**
- **timeouts** (optional)

**Walidacje i preconditions (must-have):**
- Nazwa VM zgodna z rules Azure (length + regex).
- `admin_username` i warunki auth:
  - `disable_password_authentication = true` -> wymagany `admin_ssh_key`.
  - `disable_password_authentication = false` -> wymagany `admin_password`.
- `source_image_reference` i `source_image_id` mutually exclusive.
- `plan` tylko z marketplace images (zalezne od source image).
- `availability_set_id` nie moze byc laczone z `zone`.
- `dedicated_host_id` i `dedicated_host_group_id` mutually exclusive.
- `boot_diagnostics`:
  - gdy enabled: `storage_account_uri` lub managed (wg provider schema).
- `data_disks`:
  - unikalny `lun`, unikalne `name`.
- `os_disk.disk_encryption_set_id` wymaga identity z user-assigned (jesli wymagane
  przez provider).
- `spot`:
  - `priority = Spot` -> wymagane `eviction_policy` (wg provider schema).
- `security_profile` tylko gdy wspierane przez image/region (do potwierdzenia).

**Implementation notes:**
- `locals` dla flag i map wynikowych.
- `lifecycle` preconditions dla regul cross-field.
- Nazwy zasobow i iteratorow zgodne z guide (no `this`, no skroty).

---

### TASK-038-4: Sub-resources (VM extensions)

**Cel:** Pelne wsparcie VM extensions powiazanych z Linux VM.

**Inputs:**
- `extensions`: list(object({
    name,
    publisher,
    type,
    type_handler_version,
    settings,
    protected_settings,
    auto_upgrade_minor_version,
    automatic_upgrade_enabled,
    failure_suppression_enabled,
    force_update_tag
  }))

**Wymagania:**
- `for_each` po `name` + walidacja unikalnosci.
- `settings`/`protected_settings` jako `map(any)` lub `any` + `jsonencode`.
- Opcjonalny `provision_after_extensions` (lista nazw) dla kolejnosci.
- Walidacje minimalne wg provider schema (publisher/type/version required).

---

### TASK-038-5: Diagnostic settings (inline, AKS pattern)

**Cel:** Wbudowane `azurerm_monitor_diagnostic_setting` dla VM.

**Do zrobienia:**
- `diagnostic_settings` input (lista obiektow) jak w AKS.
- `data.azurerm_monitor_diagnostic_categories` + filtracja kategorii.
- `areas` -> mapowanie na log/metric categories (lub default `all`).
- `diagnostic_settings_skipped` output jak w AKS.

---

### TASK-038-6: Dokumentacja modulu

**Cel:** Kompletne docs zgodne z MODULE_GUIDE.

**Do zrobienia:**
- `README.md` z wymaganymi markerami i sekcjami (Module Documentation,
  Security Considerations).
- `docs/README.md`:
  - Overview, Managed Resources, Usage Notes
  - Out-of-scope zasoby (VNet/subnet, NIC, NSG, public IP, RBAC, LAW, Backup)
- `docs/IMPORT.md` wg AKS (import blocks + ID collection).
- `SECURITY.md`:
  - SSH vs haslo, public IP exposure, boot diagnostics data
  - secure example (no public IP, SSH keys only)
  - checklist i typowe bledy
- `CONTRIBUTING.md` i `VERSIONING.md` zgodne z `module.json`.

---

### TASK-038-7: Examples (basic/complete/secure + feature-specific)

**Cel:** Przyklady zgodne z guide, uruchamialne lokalnie.

**Wymagane:**
- `examples/basic`: minimalny VM + VNet/subnet + NIC + public IP + SSH key.
- `examples/complete`: data disks + boot diagnostics + identity + extensions
  + diag settings + custom_data.
- `examples/secure`: brak public IP, private subnet, SSH keys only,
  security profile (secure_boot/vtpm) + encryption_at_host (jesli wspierane).

**Feature-specific (propozycje):**
- `examples/data-disks`
- `examples/boot-diagnostics`
- `examples/vm-extensions`
- `examples/spot`
- `examples/identity`
- `examples/custom-data`

**Wymagania wspolne:**
- `source = "../.."`, stale nazwy, `README.md` + `.terraform-docs.yml`.
- Zasoby pomocnicze (VNet, subnet, NIC, public IP, NSG) tworzone lokalnie
  w example.

---

### TASK-038-8: Testy (unit + integration + negative)

**Cel:** Zgodnosc z `docs/TESTING_GUIDE`.

**Unit tests (tftest.hcl):**
- walidacje auth (SSH vs password).
- `source_image_reference` vs `source_image_id`.
- `availability_set_id` vs `zone`.
- unikalnosc `data_disks.lun` i `data_disks.name`.
- `spot` rules (priority/eviction_policy).

**Integration / Terratest:**
- fixtures: `basic`, `complete`, `secure`, `vm-extensions`, `data-disks`.
- weryfikacja:
  - stan VM (size, image, os_disk)
  - data disks i boot diagnostics
  - identity assignment
  - extension provisioned state
  - diag settings (log/metric categories)

**Negatywne:**
- brak `admin_ssh_key` przy `disable_password_authentication = true`.
- brak `admin_password` przy `disable_password_authentication = false`.
- jednoczesne ustawienie `source_image_reference` i `source_image_id`.
- `availability_set_id` + `zone` jednoczesnie.

---

### TASK-038-9: Automatyzacja i release

**Cel:** Spojna automatyzacja i dokumentacja.

**Do zrobienia:**
- `tests/Makefile`, `test_env.sh`, `run_tests_*` jak w AKS.
- `generate-docs.sh` zgodny z guide.
- Aktualizacja `docs/_TASKS/README.md` po wdrozeniu.
- Wpis w `docs/_CHANGELOG/` dla nowego modulu.

---

## Acceptance Criteria

- Modul `modules/azurerm_linux_virtual_machine` spelnia layout z MODULE_GUIDE.
- Pokrycie wszystkich funkcji z feature matrix + potwierdzonych w provider schema.
- README/SECURITY/IMPORT/CONTRIBUTING/VERSIONING kompletne i spojne.
- Examples basic/complete/secure + feature-specific gotowe i uruchamialne.
- Testy unit + integration + negative przechodza lokalnie.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md` (status + statystyki)
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-linux-virtual-machine.md`
- `modules/README.md` (nowy modul w tabeli AzureRM)
- `README.md` (badges + tabela "Available Modules")
