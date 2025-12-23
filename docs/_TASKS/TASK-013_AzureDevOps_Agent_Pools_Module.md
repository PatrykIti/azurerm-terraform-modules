# TASK-013: Azure DevOps Agent Pools Module
# FileName: TASK-013_AzureDevOps_Agent_Pools_Module.md

**Priority:** 🟡 Medium
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-010
**Status:** ⏳ **To Do**

---

## Overview

Moduł do zarządzania pulami agentów i kolejkami w projekcie oraz elastic pools.

## Scope (Provider Resources)

- `azuredevops_agent_pool`
- `azuredevops_agent_queue`
- `azuredevops_elastic_pool`

## Module Design

### Inputs

- agent_pools (list(object)): name, auto_provision, auto_update, pool_type.
- agent_queues (list(object)): project_id, name, agent_pool_id.
- elastic_pools (list(object)): name, service_endpoint_id, azure_resource_id, desired_idle, max_capacity.

### Outputs

- agent_pool_ids
- agent_queue_ids
- elastic_pool_ids

### Notes

- agent_queue jest project-scoped; agent_pool i elastic_pool org-level.

## Examples

- basic: jedna pula + kolejka w projekcie.
- complete: kilka pul + elastic pool (np. Azure VMSS).
- secure: ograniczone uprawnienia do kolejek + minimalne capacity.

## Tests

- Unit: walidacje zmiennych, typy, wymagane pola.
- Integration: create/update/delete w realnym ADO (env: AZDO_ORG_SERVICE_URL, AZDO_PERSONAL_ACCESS_TOKEN).
- Negative: błędne kombinacje (np. brak project_id tam gdzie wymagany).

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-<module>.md`

## Acceptance Criteria

- Moduł `modules/azuredevops_agent_pools` zgodny z wzorcem `modules/azurerm_kubernetes_cluster/`.
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
