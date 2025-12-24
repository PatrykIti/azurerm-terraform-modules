# TASK-ADO-006: Azure DevOps Repository Module
# FileName: TASK-ADO-006_AzureDevOps_Repository_Module.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Large
**Dependencies:** TASK-ADO-001
**Status:** ✅ **Done** (2025-12-24)

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
- repositories (map(object)): name, initialization (init_type, source_type, source_url, service_connection_id, username, password), parent_repository_id, disabled, default_branch.
- branches (list(object)): repository_id lub repository_key, name, ref_branch/ref_tag/ref_commit_id.
- files (list(object)): repository_id lub repository_key, file, content, branch, commit_message, author/committer metadata.
- git_permissions (list(object)): repository_id lub repository_key, branch_name, principal, permissions, replace.
- branch_policy_* (list(object) per typ): settings + scope z repository_id lub repository_key.
- repository_policy_* (list(object) per typ): parametry + repository_ids lub repository_keys.

### Outputs

- repository_ids
- repository_urls
- branch_ids
- policy_ids

### Notes

- Spójny obszar: repo + policy + permissions. Inputy podzielone per typ polityki.
- Wiele obiektów wspiera `repository_key` do mapowania na repo utworzone w module.

## Examples

- basic: repo z inicjalnym plikiem README.
- complete: repo + branch + permissions + wybrane polityki.
- secure: polityki wymagające code review + status checks.

## Tests

- Unit: walidacje zmiennych, typy, wymagane pola.
- Integration: create/update/delete w realnym ADO (env: AZDO_ORG_SERVICE_URL, AZDO_PERSONAL_ACCESS_TOKEN, AZDO_PROJECT_ID).
- Negative: błędne kombinacje (np. repository_id i repository_key jednocześnie).

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
