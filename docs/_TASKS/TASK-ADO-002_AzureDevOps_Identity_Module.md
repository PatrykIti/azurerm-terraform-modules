# TASK-ADO-002: Azure DevOps Identity Module
# FileName: TASK-ADO-002_AzureDevOps_Identity_Module.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Large
**Dependencies:** —
**Status:** ✅ **Done** (2025-12-23)

---

## Overview

Moduł org-level do zarządzania tożsamościami i uprawnieniami globalnymi: grupy, członkostwa, entitlements oraz przypisania ról.

## Scope (Provider Resources)

- `azuredevops_group`
- `azuredevops_group_membership`
- `azuredevops_group_entitlement`
- `azuredevops_user_entitlement`
- `azuredevops_service_principal_entitlement`
- `azuredevops_securityrole_assignment`

## Module Design

### Inputs

- groups (map(object)): display_name, description, scope, origin_id/origin/mail.
- group_memberships (list(object)): group_descriptor lub group_key + member_descriptors/member_group_keys + mode.
- user_entitlements (list(object)): principal_name lub origin+origin_id + account_license_type + licensing_source.
- group_entitlements (list(object)): display_name lub origin+origin_id + account_license_type + licensing_source.
- service_principal_entitlements (list(object)): origin_id + account_license_type + licensing_source.
- securityrole_assignments (list(object)): scope, resource_id, role_name, identity_id lub identity_group_key.

### Outputs

- group_ids
- group_descriptors
- group_entitlement_ids
- group_entitlement_descriptors
- user_entitlement_ids
- user_entitlement_descriptors
- service_principal_entitlement_ids
- service_principal_entitlement_descriptors
- group_membership_ids

### Notes

- Moduł org-level. Wykorzystywany przez project/repo/pipelines/serviceendpoint do pobierania descriptorów oraz ID.

## Examples

- basic: utworzenie jednej grupy.
- complete: grupy + memberships + opcjonalne entitlements/role assignments.
- secure: jawne memberships (overwrite) + minimalne entitlements.

## Tests

- Unit: walidacje zmiennych, typy, wymagane pola.
- Integration: create/update/delete w realnym ADO (env: AZDO_ORG_SERVICE_URL, AZDO_PERSONAL_ACCESS_TOKEN).
- Negative: błędne kombinacje (np. group_descriptor i group_key jednocześnie).

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
