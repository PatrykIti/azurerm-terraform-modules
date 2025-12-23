# TASK-011: Azure DevOps Identity Module
# FileName: TASK-011_AzureDevOps_Identity_Module.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Large
**Dependencies:** —
**Status:** ⏳ **To Do**

---

## Overview

Moduł organizacyjny do zarządzania tożsamościami i uprawnieniami globalnymi: grupy, członkostwa i entitlements dla user/SP.

## Scope (Provider Resources)

- `azuredevops_group`
- `azuredevops_group_membership`
- `azuredevops_group_entitlement`
- `azuredevops_user_entitlement`
- `azuredevops_service_principal_entitlement`
- `azuredevops_securityrole_assignment`

## Module Design

### Inputs

- groups (list(object)): name, description, scope (org/project), origin_id.
- group_memberships (list(object)): group_descriptor + member_descriptors.
- user_entitlements (list(object)): principal_name, license, extensions, project entitlements.
- group_entitlements (list(object)): descriptor + license + project entitlements.
- service_principal_entitlements (list(object)): application_id, license, project entitlements.
- securityrole_assignments (list(object)): scope, role_name, subject_descriptor.

### Outputs

- group_ids
- group_descriptors
- user_entitlement_ids
- service_principal_entitlement_ids

### Notes

- Moduł org-level. Wykorzystywany przez project/repo/pipelines/serviceendpoint do permission descriptors.

## Examples

- basic: utworzenie jednej grupy i przypisanie członków.
- complete: grupy + entitlements + role assignments.
- secure: minimalne licencje i role, brak nadmiarowych uprawnień.

## Tests

- Unit: walidacje zmiennych, typy, wymagane pola.
- Integration: create/update/delete w realnym ADO (env: AZDO_ORG_SERVICE_URL, AZDO_PERSONAL_ACCESS_TOKEN).
- Negative: błędne kombinacje (np. brak project_id tam gdzie wymagany).

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-<module>.md`

## Acceptance Criteria

- Moduł `modules/azuredevops_identity` zgodny z wzorcem `modules/azurerm_kubernetes_cluster/`.
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
