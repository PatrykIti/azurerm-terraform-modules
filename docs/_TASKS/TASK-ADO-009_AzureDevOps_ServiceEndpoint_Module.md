# TASK-ADO-009: Azure DevOps Service Endpoints Module
# FileName: TASK-ADO-009_AzureDevOps_ServiceEndpoint_Module.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Large
**Dependencies:** TASK-ADO-001
**Status:** ✅ **Done** (2025-12-24)

---

## Overview

Wszystkie service endpoint typy w jednym module obszarowym + permissions.

## Scope (Provider Resources)

- `azuredevops_serviceendpoint_argocd`
- `azuredevops_serviceendpoint_artifactory`
- `azuredevops_serviceendpoint_aws`
- `azuredevops_serviceendpoint_azure_service_bus`
- `azuredevops_serviceendpoint_azurecr`
- `azuredevops_serviceendpoint_azuredevops`
- `azuredevops_serviceendpoint_azurerm`
- `azuredevops_serviceendpoint_bitbucket`
- `azuredevops_serviceendpoint_black_duck`
- `azuredevops_serviceendpoint_checkmarx_one`
- `azuredevops_serviceendpoint_checkmarx_sast`
- `azuredevops_serviceendpoint_checkmarx_sca`
- `azuredevops_serviceendpoint_dockerregistry`
- `azuredevops_serviceendpoint_dynamics_lifecycle_services`
- `azuredevops_serviceendpoint_externaltfs`
- `azuredevops_serviceendpoint_gcp_terraform`
- `azuredevops_serviceendpoint_generic`
- `azuredevops_serviceendpoint_generic_git`
- `azuredevops_serviceendpoint_generic_v2`
- `azuredevops_serviceendpoint_github`
- `azuredevops_serviceendpoint_github_enterprise`
- `azuredevops_serviceendpoint_gitlab`
- `azuredevops_serviceendpoint_incomingwebhook`
- `azuredevops_serviceendpoint_jenkins`
- `azuredevops_serviceendpoint_jfrog_artifactory_v2`
- `azuredevops_serviceendpoint_jfrog_distribution_v2`
- `azuredevops_serviceendpoint_jfrog_platform_v2`
- `azuredevops_serviceendpoint_jfrog_xray_v2`
- `azuredevops_serviceendpoint_kubernetes`
- `azuredevops_serviceendpoint_maven`
- `azuredevops_serviceendpoint_nexus`
- `azuredevops_serviceendpoint_npm`
- `azuredevops_serviceendpoint_nuget`
- `azuredevops_serviceendpoint_octopusdeploy`
- `azuredevops_serviceendpoint_openshift`
- `azuredevops_serviceendpoint_permissions`
- `azuredevops_serviceendpoint_runpipeline`
- `azuredevops_serviceendpoint_servicefabric`
- `azuredevops_serviceendpoint_snyk`
- `azuredevops_serviceendpoint_sonarcloud`
- `azuredevops_serviceendpoint_sonarqube`
- `azuredevops_serviceendpoint_ssh`
- `azuredevops_serviceendpoint_visualstudiomarketplace`

## Module Design

### Inputs

- project_id (string).
- serviceendpoint_* (list(object) per typ): parametry specyficzne dla danego endpointu.
- serviceendpoint_permissions (list(object)): endpoint_id + principal_descriptor + permissions.

### Outputs

- serviceendpoint_ids
- serviceendpoint_names

### Notes

- Zalecany schemat: osobne listy per typ endpointu (czytelne walidacje, brak unii typów).

## Examples

- basic: azurerm + dockerregistry.
- complete: mix typów (github, aws, kubernetes) + permissions.
- secure: minimalne uprawnienia i ograniczone typy.

## Tests

- Unit: walidacje zmiennych, typy, wymagane pola.
- Integration: create/update/delete w realnym ADO (env: AZDO_ORG_SERVICE_URL, AZDO_PERSONAL_ACCESS_TOKEN).
- Negative: błędne kombinacje (np. brak project_id tam gdzie wymagany).

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-<module>.md`

## Acceptance Criteria

- Moduł `modules/azuredevops_serviceendpoint` zgodny z wzorcem `modules/azurerm_kubernetes_cluster/`.
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
