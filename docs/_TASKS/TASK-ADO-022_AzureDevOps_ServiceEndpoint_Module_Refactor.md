# TASK-ADO-022: Azure DevOps Service Endpoint Module Refactor
# FileName: TASK-ADO-022_AzureDevOps_ServiceEndpoint_Module_Refactor.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Large
**Dependencies:** TASK-ADO-009
**Status:** ✅ **Done** (2025-12-26)

---

## Overview

Refactor `modules/azuredevops_serviceendpoint` to align with MODULE_GUIDE/TESTING_GUIDE/TERRAFORM_BEST_PRACTICES.
Focus on stable for_each keys, explicit cross-field validation for authentication modes, secure handling of secrets,
and a permissions workflow that can reference module-created endpoints. Document any provider-driven deviations.

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

## Current Gaps (Summary)

- All endpoint resources and permissions use index-based `for_each`, producing unstable addresses.
- Outputs (`serviceendpoint_ids`, `serviceendpoint_names`) are keyed by index instead of stable keys.
- No `key` inputs or uniqueness validation for any endpoint list or permissions list.
- `serviceendpoint_permissions` makes `serviceendpoint_id` optional, but the resource needs it; examples/fixtures omit it
  and there is no lookup path to module-created endpoints.
- Cross-field validation is missing for auth modes (token vs basic), AWS OIDC vs access keys, Kubernetes
  `authorization_type` vs blocks, OpenShift/Service Fabric auth blocks, SSH password vs private key, GitHub PAT vs OAuth,
  and other provider rules.
- Sensitive values (tokens, passwords, private keys, client secrets) are not marked `sensitive`.
- Examples rely on `random` provider and dynamic names (violates fixed-name examples rule).
- Missing `docs/IMPORT.md` for the module.
- Tests are minimal and do not cover key uniqueness, permission lookups, or auth-mode validation.

## Target Module Design

### Inputs (Common Pattern)

Keep separate `serviceendpoint_*` lists per type, add stable keys:
- `key` (optional string) for all `serviceendpoint_*` objects.
- `for_each` key = `coalesce(key, service_endpoint_name, name)` (generic_v2 uses `name`).
- Add uniqueness validation per list; reject empty or duplicate keys.
- Add non-empty validation for required string fields.

### Inputs (Permissions)

`serviceendpoint_permissions` (list(object)):
- key (optional string)
- serviceendpoint_id (optional string)
- serviceendpoint_type (optional string; matches `serviceendpoint_ids` keys)
- serviceendpoint_key (optional string; matches endpoint key/name)
- principal (string)
- permissions (map(string))
- replace (optional bool, default true)

Validation rules:
- exactly one of `serviceendpoint_id` or (`serviceendpoint_type` + `serviceendpoint_key`)
- principal non-empty
- permissions values in ["Allow", "Deny", "NotSet"]
- `serviceendpoint_type` must be one of supported types
- for_each key = `coalesce(key, "${serviceendpoint_type or serviceendpoint_id}:${principal}")`

Implementation notes:
- build `local.serviceendpoint_ids` map from resources and resolve IDs for permissions via `coalesce(...)`
  with `try()`/preconditions.

### Inputs (Auth and Mode Validation)

Add cross-field validation per provider rules, at minimum:
- token-vs-basic endpoints (argocd/artifactory/jfrog/maven/visualstudiomarketplace): require exactly one auth block.
- GitHub/GitHub Enterprise: require exactly one of PAT or OAuth (consolidate to nested `auth_*` if possible;
  otherwise validate mutual exclusion with top-level fields).
- AWS: require either access key pair or OIDC fields; forbid mixed modes.
- AzureRM: enforce scheme-specific requirements (service principal secret vs certificate vs workload identity).
- Kubernetes: enforce `authorization_type` values and the corresponding auth block only.
- OpenShift: exactly one of `auth_basic`, `auth_token`, `auth_none`.
- Service Fabric: exactly one of `certificate`, `azure_active_directory`, `none`.
- SSH: require exactly one of `password` or `private_key`.
- NuGet: enforce a single auth method when credentials are supplied.

### Sensitive Inputs

Mark all secret/token/password/private_key fields as `sensitive = true` in `variables.tf`.

### Outputs

- Keep `serviceendpoint_ids` and `serviceendpoint_names`, keyed by stable keys (not index).
- Key `permissions` output by stable permission key.

### Examples

- Replace random naming with fixed names in basic/complete/secure.
- Add a permissions example that references a module-created endpoint via `serviceendpoint_type` + `serviceendpoint_key`.
- Ensure examples are self-contained and runnable.

### Tests

Update per TESTING_GUIDE:
- Unit: key uniqueness, permission lookup validation, and auth-mode validations (GitHub, Kubernetes, OpenShift, SSH, AWS).
- Integration: create a generic endpoint and permissions that resolve via key/type.
- Negative: invalid auth combinations and missing permission targets.

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-serviceendpoint-refactor.md`

## Acceptance Criteria

- All service endpoints use stable keys with uniqueness validation.
- `serviceendpoint_permissions` can resolve module-created endpoints or accept explicit IDs with validation.
- Sensitive values are marked as `sensitive`.
- Examples use fixed names and include a permissions workflow.
- `docs/IMPORT.md` added.
- Unit + integration + negative tests updated and passing.

## Implementation Checklist

- [ ] Refactor variables.tf: add `key` to all endpoint lists, add validations, mark sensitive fields.
- [ ] Refactor main.tf: replace index-based `for_each` with stable keys; add locals for key maps and permissions lookup.
- [ ] Refactor outputs.tf: stable-keyed maps and permissions output.
- [ ] Update examples and fixtures: fixed names and permissions referencing module endpoints.
- [ ] Add docs/IMPORT.md.
- [ ] Update tests (unit, fixtures, terratest, test_config).
- [ ] make docs + update README.
