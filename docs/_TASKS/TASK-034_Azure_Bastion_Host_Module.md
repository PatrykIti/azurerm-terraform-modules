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

## Audit Subtasks (2026-02-07)

**Status gate (docs/MODULE_GUIDE/11-scope-and-provider-coverage-status-check.md):**
- Scope Status: **GREEN**
- Provider Coverage Status: **YELLOW**
- Overall Status: **YELLOW**
- Audit mode: `AUDIT_ONLY`
- Primary resource: `azurerm_bastion_host` (`azurerm` `4.57.0`)

### 1) Scope boundary + atomicity (Checklist 10 + 11.A)

- [x] Potwierdzic zgodnosc nazwy folderu i intencji modulu: `modules/azurerm_bastion_host`.
- [x] Potwierdzic, ze primary resource w kodzie to `azurerm_bastion_host` (`main.tf`), a inline exception to tylko `azurerm_monitor_diagnostic_setting` (`diagnostics.tf`).
- [x] Potwierdzic brak cross-resource glue w module (RBAC, private endpoint, budgets, NSG/UDR, networking orchestration poza modulem).
- [x] Potwierdzic, ze `docs/README.md` ma jawna sekcje `Out of Scope` i jest spojna z kodem/examples.
- [ ] Dodac do tego taska mini-mape dowodow `scope -> file:line`, zeby review PR mogl szybko zatwierdzic gate bez ponownego audytu.

### 2) Provider capability coverage - PRIMARY_RESOURCE (`azurerm_bastion_host`) (11.B + 11.C)

- [x] Potwierdzic pokrycie argumentow/blocks resource: `name`, `resource_group_name`, `location`, `sku`, `scale_units`, `copy_paste_enabled`, `file_copy_enabled`, `ip_connect_enabled`, `kerberos_enabled`, `shareable_link_enabled`, `tunneling_enabled`, `session_recording_enabled`, `virtual_network_id`, `zones`, `ip_configuration`, `timeouts`, `tags`.
- [x] Potwierdzic walidacje i preconditions cross-field (Developer vs Basic/Standard/Premium; Standard/Premium feature gates; Premium-only session recording).
- [ ] Uzupelnic formalna **Coverage Matrix** (capability-by-capability z kolumnami `Implemented/Omitted/N-A`, severity, evidence `file:line`) i utrzymywac ja w tasku az do zamkniecia.
- [ ] Wykonac/podpiac schema diff dla `azurerm_bastion_host` (`4.57.0`) i zaznaczyc ewentualne odstepstwa jako jawne decyzje.

### 3) Provider coverage - diagnostic settings companion (`azurerm_monitor_diagnostic_setting`)

- [x] Potwierdzic inline diagnostics pattern zgodny z filozofia atomic module (diagnostic settings jako dozwolony inline wyjatek).
- [x] Rozstrzygnac i udokumentowac czy module ma wspierac `partner_solution_id` (albo jawnie oznaczyc jako intentional omission).
- [x] Rozstrzygnac i udokumentowac czy module ma wspierac `enabled_log.category_group` / `log_category_groups` (albo jawnie oznaczyc jako intentional omission).
- [x] Dodac testy + dokumentacje dla wybranej decyzji (implementacja albo kontrolowane pominiecie z uzasadnieniem).

Decyzja (2026-02-07):
- `partner_solution_id`: **Implemented** w `modules/azurerm_bastion_host/variables.tf` i `modules/azurerm_bastion_host/diagnostics.tf`.
- `log_category_groups` / `enabled_log.category_group`: **Implemented** w `modules/azurerm_bastion_host/variables.tf` i `modules/azurerm_bastion_host/diagnostics.tf` (z filtrowaniem do categories/groups expose'owanych przez `data.azurerm_monitor_diagnostic_categories`).
- Pokrycie testami/docs: `modules/azurerm_bastion_host/tests/unit/validation.tftest.hcl`, `modules/azurerm_bastion_host/tests/unit/outputs.tftest.hcl`, `modules/azurerm_bastion_host/docs/README.md`, `modules/azurerm_bastion_host/README.md`.

### 4) Module structure, docs, examples (Checklist 10 domains)

- [x] Potwierdzic pelny layout modulu: core TF files, docs, examples, tests, `module.json`, `.releaserc.js`, `.terraform-docs.yml`, `Makefile`, `generate-docs.sh`.
- [x] Potwierdzic markery README: `BEGIN_VERSION`, `BEGIN_EXAMPLES`, `BEGIN_TF_DOCS`.
- [x] Potwierdzic wymagane przyklady: `examples/basic`, `examples/complete`, `examples/secure` + feature-specific examples.
- [ ] Zaktualizowac historyczna sekcje `Feature matrix` w tym tasku (obecnie nie odzwierciedla wprost SKU `Developer` i pelnego `Premium` flow).
- [ ] Dodac plan examples/tests dla scenariuszy `Developer` i `Premium + session_recording_enabled` (albo jawnie opisac powod braku).
  - Defer: wymaga dodatkowych fixtures + integracyjnych scenariuszy runtime (wiekszy zakres niz bezpieczny audit fix).

### 5) Testing + Go tests/fixtures addendum (Checklist 10 Testing + 11.G)

- [x] Potwierdzic unit tests (`tests/unit/*.tftest.hcl`) dla defaults, naming, outputs i kluczowych walidacji.
- [x] Potwierdzic Terratest fixtures dla `basic`, `complete`, `secure`, `ip-connect`, `tunneling`, `shareable-link`, `file-copy`, `diagnostic-settings`, `negative`.
- [x] Potwierdzic `source = "../../.."` w fixtures i brak zaleznosci na sibling modules (wiec `CopyTerraformFolderToTemp(t, "..", "tests/fixtures/...")` pozostaje poprawne).
- [ ] Dodac pozytywne testy scenariuszy: `Developer` (`virtual_network_id`) oraz `Premium` (`session_recording_enabled = true`).
- [ ] Rozszerzyc negative tests o diagnostyke (brak destination, niepoprawne `areas`, niepoprawne kombinacje).
- [x] Domknac zgodnosc `tests/Makefile` z addendum: wszystkie targety `test-*` powinny korzystac z `run_with_log` (uzupelnic `test-quick`, `test-junit`).
- [x] Dodac i egzekwowac compile gate dla testow Go: `go test ./... -run '^$'`.
  - Defer (pozostale duze testy): pelne pozytywne scenariusze `Developer`/`Premium` i szersze negative cases wymagaja nowych fixture/integration coverage.

### 6) Release + CI/CD integration (Checklist 10 Configuration/CI)

- [x] Potwierdzic `module.json` (`name`, `title`, `commit_scope`, `tag_prefix`) i spojne mapowanie w `.releaserc.js`.
- [x] Potwierdzic obecny scope `bastion-host` w `.github/workflows/pr-validation.yml`.
- [ ] Dodac w tym tasku sekcje "audit evidence links" dla release/CI (sciezki + linie), aby reviewer mial gotowy check-pack.

### Validation commands

- [ ] `terraform -chdir=modules/azurerm_bastion_host fmt -check -recursive`
- [ ] `terraform -chdir=modules/azurerm_bastion_host init -backend=false -input=false`
- [ ] `terraform -chdir=modules/azurerm_bastion_host validate`
- [ ] `terraform -chdir=modules/azurerm_bastion_host test -test-directory=tests/unit`
- [ ] `cd modules/azurerm_bastion_host/tests && go test ./... -run '^$'`

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
