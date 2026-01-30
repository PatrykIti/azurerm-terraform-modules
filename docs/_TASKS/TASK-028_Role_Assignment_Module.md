# TASK-028: Role Assignment module (RBAC) + zaleznosci
# FileName: TASK-028_Role_Assignment_Module.md

**Priority:** High  
**Category:** New Module / Security (RBAC)  
**Estimated Effort:** Medium  
**Dependencies:** -  
**Status:** To Do

---

## Cel

Stworzyc nowe moduly zgodne z repo standardami:
- `modules/azurerm_role_assignment`
- `modules/azurerm_role_definition` (dependency dla custom roles)

Moduly musza byc zgodne z:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

AKS jest wzorcem struktury i testow; wszystkie odstepstwa musza byc jawnie
udokumentowane.

---

## Zakres (Provider Resources)

**Role Assignment module (primary):**
- `azurerm_role_assignment`

**Role Definition module (dependency / osobny modul):**
- `azurerm_role_definition`

**Out-of-scope (oba moduly):**
- Tworzenie principalow (Azure AD users/groups/service principals)
- Tworzenie scope'ow (management groups, subscriptions, resource groups, resources)
- PIM / role management policies / eligibility schedules
- Cross-resource glue (private endpoints, networking, monitoring, itp.)

---

## Zalozenia i decyzje

1) **Atomic scope**  
   Kazdy modul zarzadza jednym primary resource (jedna rola / jedno przypisanie).

2) **Brak cross-resource glue**  
   Modul przyjmuje tylko ID scope'ow i principali. Brak tworzenia lub lookupu
   zaleznosci w module.

3) **Security-first**  
   Brak domyslnych uprawnien. Wymagane jawne wskazanie scope i role definition.
   Ryzyka (Owner/Contributor, szerokie assignable scopes, ABAC) opisane w
   `SECURITY.md`.

4) **Spojny UX**  
   Inputs pogrupowane logicznie, walidacje w `variables.tf`, zaleznosci
   cross-field jako `lifecycle` preconditions w `main.tf`.

---

## Feature matrix (musi byc pokryty)

**Role Assignment:**
- scope: management group / subscription / resource group / resource
- role definition: `role_definition_id` lub `role_definition_name`
- principal: `principal_id` + opcjonalny `principal_type`
- optional: `description`, `condition`, `condition_version`
- delegated assignment: `delegated_managed_identity_resource_id`
- safety flag: `skip_service_principal_aad_check`
- timeouts (jesli wspierane)

**Role Definition:**
- role metadata: name/display name, description (wg provider schema)
- permissions: `actions`, `not_actions`, `data_actions`, `not_data_actions`
- `assignable_scopes`
- `scope` (root dla definicji)
- timeouts (jesli wspierane)

---

## Zakres i deliverables

### TASK-028-1: Discovery / feature inventory

**Cel:** Potwierdzic schema provider `azurerm` 4.57.0 dla RBAC resources.

**Do zrobienia:**
- Sprawdzic schema provider `azurerm` (doc lub `terraform providers schema -json`)
  dla:
  - `azurerm_role_assignment`
  - `azurerm_role_definition`
- Potwierdzic dokladne nazwy pol, wymagane kombinacje i dozwolone wartosci.
- Zweryfikowac:
  - czy `name` w role assignment to GUID (format/length)
  - enumy `principal_type`
  - wymagania dla `condition` + `condition_version`
  - wymagania dla `delegated_managed_identity_resource_id`
  - zachowanie `skip_service_principal_aad_check`
- Spisac finalny zestaw walidacji, preconditions i examples.

---

### TASK-028-2: Scaffold modulu `azurerm_role_assignment`

**Cel:** Pelna struktura modulu zgodna z guide.

**Checklist:**
- [ ] `modules/azurerm_role_assignment/` utworzony przez
      `scripts/create-new-module.sh` (wymagane).
- [ ] `module.json`:
  - name: `azurerm_role_assignment`
  - commit_scope: `role-assignment`
  - tag_prefix: `RAv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] `.releaserc.js`, `.terraform-docs.yml`, `Makefile`, `generate-docs.sh`
      zgodne z AKS.
- [ ] Pliki bazowe: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`,
      `VERSIONING.md`, `SECURITY.md`, `docs/IMPORT.md`.

---

### TASK-028-3: Scaffold modulu `azurerm_role_definition`

**Cel:** Pelna struktura modulu dependency dla custom roles.

**Checklist:**
- [ ] `modules/azurerm_role_definition/` utworzony przez
      `scripts/create-new-module.sh` (wymagane).
- [ ] `module.json`:
  - name: `azurerm_role_definition`
  - commit_scope: `role-definition`
  - tag_prefix: `RDv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] Pliki bazowe + docs jak w TASK-026-2.

---

### TASK-028-4: Core resource `azurerm_role_assignment`

**Cel:** Implementacja pelnego API role assignment w `main.tf` + walidacje w `variables.tf`.

**Zakres (propozycja inputow):**
- **core**: `name` (opcjonalne GUID), `scope`, `description`
- **role**: `role_definition_id` / `role_definition_name`
- **principal**: `principal_id`, `principal_type`
- **condition**: `condition`, `condition_version`
- **delegated**: `delegated_managed_identity_resource_id`
- **flags**: `skip_service_principal_aad_check`
- **timeouts** (optional)

**Walidacje i preconditions (must-have):**
- Dokladnie jedno z `role_definition_id` lub `role_definition_name`.
- `principal_id` wymagany i niepusty.
- `name` (jesli ustawione) w formacie GUID.
- `condition` wymaga `condition_version`.
- `condition_version` w dozwolonym zbiorze (wg provider schema).
- `principal_type` w dozwolonych wartosciach.
- `skip_service_principal_aad_check` tylko gdy `principal_type` = ServicePrincipal
  (wg provider schema).
- `delegated_managed_identity_resource_id` tylko gdy `principal_id` wskazuje MI
  (potwierdzic w discovery).
- `scope` niepusty i zgodny z formatem ARM ID.

**Implementation notes:**
- `locals` dla flag i map wynikowych.
- `lifecycle` preconditions dla regul cross-field.
- Nazwy zasobow i iteratorow zgodne z guide (no `this`, no skroty).

---

### TASK-028-5: Core resource `azurerm_role_definition`

**Cel:** Implementacja pelnego API role definition w `main.tf` + walidacje w `variables.tf`.

**Zakres (propozycja inputow):**
- **core**: `name`/`role_name` (wg schema), `description`, `scope`
- **permissions**: `permissions` list(object({
    actions, not_actions, data_actions, not_data_actions
  }))
- **assignable_scopes**: list(string)
- **timeouts** (optional)

**Walidacje i preconditions (must-have):**
- `permissions` niepuste, co najmniej jeden action lub data_action.
- `assignable_scopes` niepuste.
- `assignable_scopes` musza zawierac `scope` (lub byc jego child scope) - wg schema.
- Walidacje nazw (jesli `name` wymaga GUID, walidowac format).

**Implementation notes:**
- `for_each` tylko tam, gdzie wymagane przez schema (permissions).
- `lifecycle` preconditions dla relacji `scope`/`assignable_scopes`.

---

### TASK-028-6: Dokumentacja modulow

**Cel:** Kompletne docs zgodne z MODULE_GUIDE.

**Do zrobienia (dla obu modulow):**
- `README.md` z wymaganymi markerami (BEGIN_VERSION / EXAMPLES / TF_DOCS).
- `docs/README.md`:
  - Overview, Managed Resources, Usage Notes
  - Out-of-scope: tworzenie principalow i scope'ow.
- `docs/IMPORT.md` z import blocks i sposobem zbudowania ID.
- `SECURITY.md`:
  - least privilege
  - ryzyka Owner/Contributor i szerokich scope'ow
  - ABAC / conditions
  - `skip_service_principal_aad_check` jako trade-off
- `CONTRIBUTING.md` i `VERSIONING.md` zgodne z `module.json`.

---

### TASK-028-7: Examples (basic/complete/secure + feature-specific)

**Role Assignment:**
- `examples/basic`: Reader na RG dla user-assigned identity.
- `examples/complete`: wlasne `name` GUID + `principal_type` + `description`
  + optional `condition`.
- `examples/secure`: least-privilege custom role (z `azurerm_role_definition`)
  + assignment na ograniczonym scope.

**Role Definition:**
- `examples/basic`: minimal custom role (actions).
- `examples/complete`: actions + data_actions + not_actions.
- `examples/secure`: minimalne actions + scope ograniczony do RG.

**Feature-specific (propozycje):**
- `examples/management-group-scope`
- `examples/subscription-scope`
- `examples/resource-scope`
- `examples/abac-condition`
- `examples/delegated-managed-identity`

**Wymagania wspolne:**
- `source = "../.."`, stale nazwy, `README.md` + `.terraform-docs.yml`.
- Zasoby pomocnicze (RG, storage/keyvault, user-assigned identity) tworzone
  lokalnie w example.

---

### TASK-028-8: Testy (unit + integration + negative)

**Unit tests (tftest.hcl):**
- `role_definition_id` vs `role_definition_name` (mutual exclusivity).
- `name` GUID validation.
- `condition` wymaga `condition_version`.
- `principal_type` w dozwolonych wartosciach.
- `assignable_scopes` niepuste i zawieraja `scope`.

**Integration / Terratest:**
- fixtures: `basic` (built-in role), `secure` (custom role), `abac-condition`.
- tworzenie MI + przypisanie roli na RG/resource scope.
- custom role definition + assignment do MI.
- opcjonalny `time_sleep` w fixture dla propagacji AAD (bez zmian w module).

**Negatywne:**
- brak `role_definition_id`/`role_definition_name`.
- `condition` bez `condition_version`.
- `assignable_scopes` puste.

---

### TASK-028-9: Automatyzacja i release

**Cel:** Spojna automatyzacja i dokumentacja.

**Do zrobienia:**
- `tests/Makefile`, `test_env.sh`, `run_tests_*` jak w AKS.
- `generate-docs.sh` zgodny z guide.
- Aktualizacja `docs/_TASKS/README.md` po wdrozeniu.
- Wpis w `docs/_CHANGELOG/` dla nowych modulow.

---

## Acceptance Criteria

- Moduly `modules/azurerm_role_assignment` i `modules/azurerm_role_definition`
  spelniaja layout z MODULE_GUIDE.
- Walidacje i preconditions pokrywaja wymagania provider schema.
- README/SECURITY/IMPORT/CONTRIBUTING/VERSIONING kompletne i spojne.
- Examples basic/complete/secure + feature-specific gotowe i uruchamialne.
- Testy unit + integration + negative przechodza lokalnie.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md` (status + statystyki)
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-role-assignment.md`
- `modules/README.md` (nowe moduly w tabeli AzureRM)
- `README.md` (badges + tabela "Available Modules")
