# TASK-ADO-012: Azure DevOps Service Hooks Module
# FileName: TASK-ADO-012_AzureDevOps_ServiceHooks_Module.md

**Priority:** 🟡 Medium
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-001
**Status:** ✅ **Done** (2025-12-24)

---

## Overview

Service hooks (webhook, storage queue) + permissions.

## Scope (Provider Resources)

- `azuredevops_servicehook_webhook_tfs`
- `azuredevops_servicehook_storage_queue_pipelines`
- `azuredevops_servicehook_permissions`

## Module Design

### Inputs

- project_id (string).
- webhooks (list(object)): url, auth/headers, event-specific filters (np. git_push, build_completed, work_item_updated).
- storage_queue_hooks (list(object)): account_name, account_key, queue_name, run_state_changed_event/stage_state_changed_event.
- servicehook_permissions (list(object)): principal, permissions, opcjonalnie project_id.

### Outputs

- servicehook_ids

### Notes

- Zadbać o maskowanie danych wrażliwych (SAS/tokeny) w outputs.

## Examples

- basic: webhook na event build.complete.
- complete: kilka hooków + permissions.
- secure: minimalne scope i ograniczone filtry.

## Tests

- Unit: walidacje zmiennych, typy, wymagane pola.
- Integration: create/update/delete w realnym ADO (env: AZDO_ORG_SERVICE_URL, AZDO_PERSONAL_ACCESS_TOKEN).
- Negative: błędne kombinacje (np. brak project_id tam gdzie wymagany).

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-<module>.md`

## Acceptance Criteria

- Moduł `modules/azuredevops_servicehooks` zgodny z wzorcem `modules/azurerm_kubernetes_cluster/`.
- Pokrycie wszystkich wskazanych resources z listy Scope.
- README generowany przez terraform-docs + kompletne examples.
- Testy unit + integration + negative dodane i przechodzą.
- Wpisy w docs/_TASKS i docs/_CHANGELOG zaktualizowane.

## Implementation Checklist

- [x] Scaffold modułu (scripts/create-new-module.sh lub manualnie) + module.json
- [x] versions.tf z azuredevops 1.12.2
- [x] variables.tf z walidacjami + domyślne bezpieczne wartości
- [x] main.tf (for_each dla list, dynamic blocks gdzie potrzebne)
- [x] outputs.tf (w tym sensitive gdzie wymagane)
- [x] examples/basic + complete + secure
- [x] tests/fixtures + unit + terratest
- [x] make docs + update README
