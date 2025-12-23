# TASK-ADO-007: Azure DevOps Pipelines Module
# FileName: TASK-ADO-007_AzureDevOps_Pipelines_Module.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Large
**Dependencies:** TASK-ADO-001
**Status:** ⏳ **To Do**

---

## Overview

Build pipelines, foldery, permissions i authorizations w jednym module.

## Scope (Provider Resources)

- `azuredevops_build_definition`
- `azuredevops_build_definition_permissions`
- `azuredevops_build_folder`
- `azuredevops_build_folder_permissions`
- `azuredevops_pipeline_authorization`
- `azuredevops_resource_authorization`

## Module Design

### Inputs

- project_id (string).
- build_definitions (list(object)): name, repository, yaml_path, agent_pool/queue, variables, triggers.
- build_folders (list(object)): path, description.
- build_definition_permissions (list(object)): build_definition_id, principal_descriptor, permissions.
- build_folder_permissions (list(object)): folder_path, principal_descriptor, permissions.
- pipeline_authorizations (list(object)): pipeline_id, resource_id, authorized.
- resource_authorizations (list(object)): project_id, resource_id, type, authorized.

### Outputs

- build_definition_ids
- build_folder_ids

### Notes

- Pipeline definitions często zależne od repo/service endpoints/agent pools - przewidzieć referencje po ID.

## Examples

- basic: jeden build definition (YAML) w root.
- complete: foldery + wiele pipeline + authorizations.
- secure: minimalne uprawnienia + jawne authorizations dla service endpoints.

## Tests

- Unit: walidacje zmiennych, typy, wymagane pola.
- Integration: create/update/delete w realnym ADO (env: AZDO_ORG_SERVICE_URL, AZDO_PERSONAL_ACCESS_TOKEN).
- Negative: błędne kombinacje (np. brak project_id tam gdzie wymagany).

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-<module>.md`

## Acceptance Criteria

- Moduł `modules/azuredevops_pipelines` zgodny z wzorcem `modules/azurerm_kubernetes_cluster/`.
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
