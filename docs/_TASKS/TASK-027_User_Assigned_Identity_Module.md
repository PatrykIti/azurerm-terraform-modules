# TASK-027: User Assigned Identity module (azurerm_user_assigned_identity)
# FileName: TASK-027_User_Assigned_Identity_Module.md

**Priority:** Medium  
**Category:** New Module / Identity  
**Estimated Effort:** Medium  
**Dependencies:** -  
**Status:** To Do

---

## Cel

Stworzyc nowy modul `modules/azurerm_user_assigned_identity` zgodny z:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

Modul ma pokrywac wszystkie funkcje dostepne w `azurerm_user_assigned_identity`
oraz powiazane sub-resources, ktore sa bezposrednio zwiazane z UAI.
AKS jest wzorcem struktury i testow; wszystkie odstepstwa musza byc jawnie
udokumentowane.

---

## Zakres (Provider Resources)

**Primary:**
- `azurerm_user_assigned_identity`

**Powiazane zasoby (w module):**
- `azurerm_federated_identity_credential`

**Potwierdzone w providerze (azurerm 4.57.0, docs):**
- `azurerm_user_assigned_identity`
- `azurerm_federated_identity_credential`

---

## Zalozenia i decyzje

1) **Atomic scope**  
   Modul zarzadza jedna User Assigned Identity jako primary resource. Dodatkowe
   zasoby tylko wtedy, gdy sa bezposrednio zwiazane z UAI (federated identity credentials).

2) **Brak cross-resource glue**  
   Poza modulem: RBAC/role assignments, Key Vault, Storage, AKS, service principals,
   federated credentials oparte o zewnetrzne zasoby. Pokazujemy je tylko w examples.

3) **Security-first**  
   Brak domyslnego tworzenia FIC — tylko przez jawny input. Ryzyka (issuer/subject/audience)
   opisane w `SECURITY.md`.

4) **Spojny styl**  
   Listy obiektow + `for_each` po `name`, walidacje w `variables.tf`, zaleznosci
   cross-field jako `lifecycle` preconditions w `main.tf`.

---

## Feature matrix (musi byc pokryty)

- name + RG + location
- tags + timeouts
- outputs: `id`, `client_id`, `principal_id`, `tenant_id`
- federated identity credentials (issuer, subject, audience[s], description jesli wspierane)

---

## Zakres i deliverables

### TASK-027-1: Discovery / feature inventory

**Cel:** Potwierdzic pelny zakres funkcji provider `azurerm` dla UAI i FIC.

**Do zrobienia:**
- Sprawdzic schema provider `azurerm` (doc lub `terraform providers schema -json`).
- Potwierdzic zasady nazewnictwa UAI (length + regex) oraz wymagane pola.
- Potwierdzic pola FIC: `issuer`, `subject`, `audience` (nazwa pola i typ), `description` (jesli wspierane).
- Spisac finalny zestaw pol i ograniczen (allowed values, required combos).
- Zaktualizowac listy walidacji, preconditions i examples na bazie realnych pol.

---

### TASK-027-2: Scaffold modulu + pliki bazowe

**Cel:** Stworzyc pelna strukture modulu zgodna z guide.

**Checklist:**
- [ ] `modules/azurerm_user_assigned_identity/` utworzony przez
      `scripts/create-new-module.sh` (wymagane).
- [ ] `module.json`:
  - name: `azurerm_user_assigned_identity`
  - commit_scope: `user-assigned-identity`
  - tag_prefix: `UAIv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] `.releaserc.js`, `.terraform-docs.yml`, `Makefile`, `generate-docs.sh`
      zgodne z AKS.
- [ ] Pliki bazowe: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`,
      `VERSIONING.md`, `SECURITY.md`, `docs/IMPORT.md`.

---

### TASK-027-3: Core resource `azurerm_user_assigned_identity`

**Cel:** Implementacja pelnego API UAI w `main.tf` + walidacje w `variables.tf`.

**Zakres (przykladowy podzial inputow):**
- **core**: `name`, `resource_group_name`, `location`, `tags`
- **timeouts** (optional)

**Walidacje i preconditions (must-have):**
- Nazwa zgodna z rules Azure (length + regex).
- `resource_group_name` i `location` niepuste.

---

### TASK-027-4: Sub-resources (federated identity credentials)

**Cel:** Pelne wsparcie `azurerm_federated_identity_credential`.

**Inputs (propozycje):**
- `federated_identity_credentials`: list(object({
    name = string
    issuer = string
    subject = string
    audiences = list(string)
    description = optional(string)
  }))

**Wymagania:**
- `for_each` po `name` + walidacja unikalnosci.
- `parent_id` wskazuje na UAI z modulu.
- Walidacje:
  - `issuer` jako poprawny URL (https).
  - `subject` non-empty.
  - `audiences` non-empty + brak pustych elementow.
- `lifecycle` preconditions dla powyzszych regul.

---

### TASK-027-5: Dokumentacja modulu

**Cel:** Kompletne docs zgodne z MODULE_GUIDE.

**Do zrobienia:**
- `README.md` z wymaganymi markerami i sekcjami (Module Documentation, Security Considerations).
- `docs/README.md`:
  - Overview, Managed Resources, Usage Notes
  - Out-of-scope zasoby (RBAC, AKS, Key Vault, Storage, workload identity binding).
- `docs/IMPORT.md` wg AKS (import blocks + ID collection) dla UAI i FIC.
- `SECURITY.md`:
  - posture (audience/issuer/subject)
  - secure example
  - checklist i typowe bledy
- `CONTRIBUTING.md` i `VERSIONING.md` zgodne z `module.json`.

---

### TASK-027-6: Examples (basic/complete/secure + feature-specific)

**Cel:** Przyklady zgodne z guide, uruchamialne lokalnie.

**Wymagane:**
- `examples/basic`: UAI bez FIC.
- `examples/complete`: UAI + tags + kilka FIC (np. GitHub Actions OIDC) + timeouts.
- `examples/secure`: UAI + FIC (bez sekretow) + minimalne RBAC do zasobu (poza modulem).

**Feature-specific (propozycje):**
- `examples/federated-identity-credentials`
- `examples/github-actions-oidc`

**Wymagania wspolne:**
- `source = "../.."`, stale nazwy, `README.md` + `.terraform-docs.yml`.
- Zasoby pomocnicze (np. storage/kv do RBAC) tworzone lokalnie w example.

---

### TASK-027-7: Testy (unit + integration + negative)

**Cel:** Zgodnosc z `docs/TESTING_GUIDE`.

**Unit tests (tftest.hcl):**
- walidacje nazw UAI.
- unikalnosc nazw FIC.
- `issuer`/`subject`/`audiences` (non-empty, format URL).
- outputs z `try()`.

**Integration / Terratest:**
- fixtures: `basic`, `complete`, `secure`, `federated-identity-credentials`.
- weryfikacja:
  - UAI properties (name, location, tags)
  - FIC count + issuer/subject/audiences
  - outputs (client_id/principal_id/tenant_id)

**Negatywne:**
- brak `issuer` lub `subject`
- puste `audiences`
- zduplikowana nazwa FIC

---

### TASK-027-8: Automatyzacja i release

**Cel:** Spojna automatyzacja i dokumentacja.

**Do zrobienia:**
- `tests/Makefile`, `test_env.sh`, `run_tests_*` jak w AKS.
- `generate-docs.sh` zgodny z guide.
- Aktualizacja `docs/_TASKS/README.md` po wdrozeniu.
- Wpis w `docs/_CHANGELOG/` dla nowego modulu.

---

## Acceptance Criteria

- Modul `modules/azurerm_user_assigned_identity` spelnia layout z MODULE_GUIDE.
- Pokrycie wszystkich funkcji z feature matrix + potwierdzonych w provider schema.
- README/SECURITY/IMPORT/CONTRIBUTING/VERSIONING kompletne i spojne.
- Examples basic/complete/secure + feature-specific gotowe i uruchamialne.
- Testy unit + integration + negative przechodza lokalnie.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md` (status + statystyki)
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-user-assigned-identity.md`
- `modules/README.md` (nowy modul w tabeli AzureRM)
- `README.md` (badges + tabela "Available Modules")
