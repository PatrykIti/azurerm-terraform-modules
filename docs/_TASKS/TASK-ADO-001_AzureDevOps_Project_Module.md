# TASK-ADO-001: Azure DevOps Project Module
# FileName: TASK-ADO-001_AzureDevOps_Project_Module.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Large
**Dependencies:** —
**Status:** ✅ **Done** (2025-12-23)

---

## Overview

Moduł startowy dla ADO. Zakłada zarządzanie projektem oraz jego kluczowymi ustawieniami, tagami i uprawnieniami, aby kolejne moduły miały stabilną bazę (project_id/descriptor).

## Scope (Provider Resources)

- `azuredevops_project`
- `azuredevops_project_pipeline_settings`
- `azuredevops_project_tags`
- `azuredevops_project_permissions`
- `azuredevops_dashboard`

## Module Design

### Inputs

- name (string): nazwa projektu.
- description (string): opis projektu (opcjonalnie).
- visibility (string): private/public.
- version_control (string): Git/Tfvc.
- work_item_template (string): Agile/Basic/CMMI/Scrum lub custom.
- features (map): mapowanie flag dla azuredevops_project.features.
- pipeline_settings (object): ustawienia z azuredevops_project_pipeline_settings.
- project_tags (list(string)): tagi projektu (azuredevops_project_tags).
- project_permissions (list(object)): principal, permissions map, replace dla azuredevops_project_permissions.
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

## Examples

- basic: minimalny projekt + domyślne features.
- complete: projekt + tags + dashboard + permissions + pipeline settings.
- secure: projekt z ograniczonymi uprawnieniami (least privilege) i minimalnymi feature-flagami.

## Tests

- Unit: walidacje zmiennych, typy, wymagane pola.
- Integration: create/update/delete w realnym ADO (env: AZDO_ORG_SERVICE_URL, AZDO_PERSONAL_ACCESS_TOKEN).
- Negative: błędne wartości (np. visibility/feature flags).

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-<module>.md`

## Acceptance Criteria

- Moduł `modules/azuredevops_project` zgodny z wzorcem `modules/azurerm_kubernetes_cluster/`.
- Pokrycie wszystkich wskazanych resources z listy Scope.
- README generowany przez terraform-docs + kompletne examples.
- Testy unit + integration + negative dodane i przechodzą.
- Wpisy w docs/_TASKS i docs/_CHANGELOG zaktualizowane.

## Implementation Checklist

- [ ] Scaffold modułu (scripts/create-new-module.sh lub manualnie) + module.json
- [ ] versions.tf z azuredevops 1.12.2
- [ ] variables.tf z walidacjami + domyślne bezpieczne wartości
- [ ] main.tf (for_each dla list, dynamic blocks gdzie potrzebne)
- [ ] outputs.tf (w tym sensitive gdzie wymagane)
- [ ] examples/basic + complete + secure
- [ ] tests/fixtures + unit + terratest
- [ ] make docs + update README
