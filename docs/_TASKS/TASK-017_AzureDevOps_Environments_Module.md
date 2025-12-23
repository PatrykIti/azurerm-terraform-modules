# TASK-017: Azure DevOps Environments Module
# FileName: TASK-017_AzureDevOps_Environments_Module.md

**Priority:** 🟡 Medium
**Category:** Azure DevOps Modules
**Estimated Effort:** Large
**Dependencies:** TASK-010
**Status:** ⏳ **To Do**

---

## Overview

Environments + checks (approvals, business hours, etc.) w jednym module.

## Scope (Provider Resources)

- `azuredevops_environment`
- `azuredevops_environment_kubernetes_resource`
- `azuredevops_check_approval`
- `azuredevops_check_branch_control`
- `azuredevops_check_business_hours`
- `azuredevops_check_exclusive_lock`
- `azuredevops_check_required_template`
- `azuredevops_check_rest_api`

## Module Design

### Inputs

- project_id (string).
- environments (list(object)): name, description.
- kubernetes_resources (list(object)): environment_id, service_endpoint_id, namespace, cluster_name.
- checks (list(object) per typ): parametry dla check_* (target_id, approvers, restrictions, schedules).

### Outputs

- environment_ids
- check_ids

### Notes

- check_* zasięg: environment lub service connection - wymagane czytelne mapowanie target_id.

## Examples

- basic: jedno environment bez checks.
- complete: env + k8s resource + approvals + branch control.
- secure: approvals + exclusive lock + business hours.

## Tests

- Unit: walidacje zmiennych, typy, wymagane pola.
- Integration: create/update/delete w realnym ADO (env: AZDO_ORG_SERVICE_URL, AZDO_PERSONAL_ACCESS_TOKEN).
- Negative: błędne kombinacje (np. brak project_id tam gdzie wymagany).

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-<module>.md`

## Acceptance Criteria

- Moduł `modules/azuredevops_environments` zgodny z wzorcem `modules/azurerm_kubernetes_cluster/`.
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
