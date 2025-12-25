# TASK-ADO-001: Azure DevOps Project Module
# FileName: TASK-ADO-001_AzureDevOps_Project_Module.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Large
**Dependencies:** —
**Status:** ✅ **Done** (2025-12-24)

---

## Overview

Moduł startowy dla ADO. Zarządza projektem i kluczowymi ustawieniami, a uprawnienia projektowe są wydzielone do osobnego modułu, aby można było budować zależności po utworzeniu projektu.

## Scope (Provider Resources)

### Project Module (this task scope)

- `azuredevops_project`
- `azuredevops_project_pipeline_settings`
- `azuredevops_project_tags`
- `azuredevops_dashboard`

### New Module: Project Permissions

- `azuredevops_project_permissions`

## Module Design

### Project Module (after cleanup)

### Inputs

- name (string): nazwa projektu.
- description (string): opis projektu (opcjonalnie).
- visibility (string): private/public.
- version_control (string): Git/Tfvc.
- work_item_template (string): Agile/Basic/CMMI/Scrum lub custom.
- features (map): mapowanie flag dla azuredevops_project.features.
- pipeline_settings (object): ustawienia z azuredevops_project_pipeline_settings.
- project_tags (list(string)): tagi projektu (azuredevops_project_tags).
- dashboards (list(object)): name, description, team_id, refresh_interval dla azuredevops_dashboard.

### Outputs

- project_id
- project_name
- project_visibility
- project_process_template_id
- dashboard_ids

### Notes

- Ten moduł jest bazą dla większości pozostałych (wymagany project_id).
- Uprawnienia projektowe są przypisywane do grup (nie pojedynczych użytkowników); członkostwa grup zarządzać przez moduł identity.

### New Module: `modules/azuredevops_project_permissions` (Option 2)

#### Inputs

- project_id (string): ID projektu ADO.
- permissions (list(object)):
  - key (optional string): stabilny klucz do for_each (np. "readers", "admins").
  - principal (optional string): descriptor grupy ADO (override, gdy znany).
  - group_name (optional string): nazwa grupy (gdy principal nieznany).
  - scope (optional string): `project` lub `collection` (wymagane, gdy group_name).
  - permissions (map(string)): mapowanie uprawnień (Allow/Deny/NotSet).
  - replace (optional bool, default true): replace/merge.

#### Resolution logic

- Dokładnie jedno z: `principal` albo `group_name` + `scope`.
- Gdy podano `group_name`:
  - `scope = "project"` → lookup przez `data.azuredevops_group` z `project_id`.
  - `scope = "collection"` → lookup przez `data.azuredevops_group` bez `project_id`.
- `principal` zawsze ma pierwszeństwo (lookup pomijany).
- for_each używa `key` (jeśli podany), w innym razie `group_name` lub `principal`.

#### Outputs

- permission_ids (map): ID zasobów permissions, kluczowane przez `key`/`group_name`/`principal`.
- permission_principals (map): resolved principal per klucz.

## Examples

- basic: minimalny projekt + domyślne features.
- complete: projekt + tags + dashboard + pipeline settings.
- secure: projekt z ograniczonymi uprawnieniami (least privilege) i minimalnymi feature-flagami.

### New Module Examples

- basic: permissions dla grupy collection (np. Project Collection Administrators) przez `group_name` + `scope=collection`.
- complete: mix `group_name` (project scope) + `principal` override.
- secure: ograniczone uprawnienia (least privilege).

## Tests

- Unit: walidacje zmiennych, typy, wymagane pola.
- Integration: create/update/delete w realnym ADO (env: AZDO_ORG_SERVICE_URL, AZDO_PERSONAL_ACCESS_TOKEN).
- Negative: błędne wartości (np. visibility/feature flags).

### New Module Tests (per docs/TESTING_GUIDE)

- Unit:
  - walidacja: dokładnie jedno z `principal` vs `group_name+scope`.
  - walidacja: scope w {project, collection}.
  - walidacja: permissions values Allow/Deny/NotSet.
  - mock_data dla `azuredevops_group` (lookup).
- Integration:
  - apply/plan dla permissions z `group_name` w scope project i collection.
  - verify outputs: permission_ids, permission_principals.
- Negative:
  - brak principal i group_name.
  - group_name bez scope.
  - duplicate keys w permissions.

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-project.md` (project cleanup)
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-project-permissions.md` (nowy moduł)

## Acceptance Criteria

- Moduł `modules/azuredevops_project` zgodny z wzorcem `modules/azurerm_kubernetes_cluster/`.
- Pokrycie wszystkich wskazanych resources z listy Scope (po podziale).
- README generowany przez terraform-docs + kompletne examples.
- Testy unit + integration + negative dodane i przechodzą.
- Wpisy w docs/_TASKS i docs/_CHANGELOG zaktualizowane.

## Implementation Checklist

### A) Cleanup `modules/azuredevops_project` (remove permissions)

- [ ] Usuń `project_permissions` input + walidacje.
- [ ] Usuń `azuredevops_project_permissions` resource i powiązane outputs.
- [ ] Zaktualizuj README + examples + SECURITY + docs/IMPORT (jeśli potrzebne).
- [ ] Zaktualizuj tests (fixtures/unit/terratest) i test_config.
- [ ] Upewnij się, że moduł jest zgodny z MODULE_GUIDE i TERRAFORM_BEST_PRACTICES.

### B) New module `modules/azuredevops_project_permissions` (Option 2)

- [ ] Scaffold modułu (scripts/create-new-module.sh lub manualnie) + module.json
- [ ] versions.tf z azuredevops 1.12.2
- [ ] variables.tf z walidacjami (principal vs group_name+scope, unique keys)
- [ ] main.tf (data azuredevops_group lookup + for_each bez indeksów)
- [ ] outputs.tf (mapy permission_ids/principals)
- [ ] examples/basic + complete + secure
- [ ] tests/fixtures + unit + terratest
- [ ] make docs + update README
