# TASK-ADO-006: Azure DevOps Repository Module
# FileName: TASK-ADO-006_AzureDevOps_Repository_Module.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Large
**Dependencies:** TASK-ADO-001
**Status:** ⏳ **To Do**

---

## Overview

Repozytoria Git + polityki branch/repo + permissions w jednym spójnym module.

## Scope (Provider Resources)

- `azuredevops_git_repository`
- `azuredevops_git_repository_branch`
- `azuredevops_git_repository_file`
- `azuredevops_git_permissions`
- `azuredevops_branch_policy_auto_reviewers`
- `azuredevops_branch_policy_build_validation`
- `azuredevops_branch_policy_comment_resolution`
- `azuredevops_branch_policy_merge_types`
- `azuredevops_branch_policy_min_reviewers`
- `azuredevops_branch_policy_status_check`
- `azuredevops_branch_policy_work_item_linking`
- `azuredevops_repository_policy_author_email_pattern`
- `azuredevops_repository_policy_case_enforcement`
- `azuredevops_repository_policy_check_credentials`
- `azuredevops_repository_policy_file_path_pattern`
- `azuredevops_repository_policy_max_file_size`
- `azuredevops_repository_policy_max_path_length`
- `azuredevops_repository_policy_reserved_names`

## Module Design

### Inputs

- project_id (string).
- repositories (list(object)): name, initialization, default_branch, parent_repository_id, etc.
- branches (list(object)): repository_id, name, ref_branch.
- files (list(object)): repository_id, branch, file_path, content, commit_message.
- git_permissions (list(object)): repository_id, principal_descriptor, permissions.
- branch_policies (list(object) per typ): parametry dla branch_policy_*.
- repository_policies (list(object) per typ): parametry dla repository_policy_*.

### Outputs

- repository_ids
- repository_urls
- branch_ids
- policy_ids

### Notes

- Spójny obszar: repo + policy + permissions. Rozdzielić inputy per typ polityki aby zachować walidacje.

## Examples

- basic: repo z inicjalnym plikiem README.
- complete: repo + branch policies + repo policies + permissions.
- secure: polityki wymagające code review + status checks.

## Tests

- Unit: walidacje zmiennych, typy, wymagane pola.
- Integration: create/update/delete w realnym ADO (env: AZDO_ORG_SERVICE_URL, AZDO_PERSONAL_ACCESS_TOKEN).
- Negative: błędne kombinacje (np. brak project_id tam gdzie wymagany).

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-<module>.md`

## Acceptance Criteria

- Moduł `modules/azuredevops_repository` zgodny z wzorcem `modules/azurerm_kubernetes_cluster/`.
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
