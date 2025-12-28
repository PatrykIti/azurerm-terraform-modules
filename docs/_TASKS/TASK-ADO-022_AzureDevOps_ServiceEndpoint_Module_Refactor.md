# TASK-ADO-022: Azure DevOps Service Endpoint Module Refactor
# FileName: TASK-ADO-022_AzureDevOps_ServiceEndpoint_Module_Refactor.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Large
**Dependencies:** TASK-ADO-009
**Status:** 🟠 **Re-opened**

---

## Overview

Refactor `modules/azuredevops_serviceendpoint` to align with MODULE_GUIDE/TESTING_GUIDE/TERRAFORM_BEST_PRACTICES.
Focus on stable for_each keys, explicit cross-field validation for authentication modes, secure handling of secrets,
and a permissions workflow that can reference module-created endpoints. Document any provider-driven deviations.
The main service endpoint must be a single (non-iterated) resource with flat inputs; for multiple endpoints use module-level `for_each`.

## Updated Rules (Re-opened)

- Main resource is single (non-iterated); use module-level `for_each` in environment config to manage multiple instances.
- Prefer `list(object)` for collections; use `map` only when provider requires key/value semantics.
- Use simple, stable `for_each` keys based on unique fields (name, principal_id, service_principal_id, group_name, etc.); never index-based.
- Follow docs/MODULE_GUIDE/, docs/TESTING_GUIDE, docs/TERRAFORM_BEST_PRACTICES_GUIDE.md.

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

- Endpoint resources are modeled as lists and iterated; should be a single endpoint per module instance with module-level `for_each`.
- All endpoint resources and permissions use index-based `for_each`, producing unstable addresses.
- Outputs (`serviceendpoint_ids`, `serviceendpoint_names`) are keyed by index instead of single values for a module instance.
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

### Inputs (Endpoint)

Single endpoint per module instance. Use one optional object per endpoint type (matching provider schema), not lists.
Validate that exactly one endpoint type object is set and required string fields are non-empty.
Use `list(object)` for any nested collections where the provider supports them; keep maps only when the provider requires map semantics.

### Inputs (Permissions)

`serviceendpoint_permissions` (list(object)):
- key (optional string)
- serviceendpoint_id (optional string)
- principal (string)
- permissions (map(string))
- replace (optional bool, default true)

Validation rules:
- serviceendpoint_id must be non-empty when provided
- when serviceendpoint_id is omitted, the module endpoint must be present
- principal non-empty
- permissions values in ["Allow", "Deny", "NotSet"]
- for_each key = `coalesce(key, principal)`

Implementation notes:
- resolve permission targets to the module-created endpoint ID when `serviceendpoint_id` is omitted.

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

- `serviceendpoint_id` (string)
- `serviceendpoint_name` (string)
- Key `permissions` output by stable permission key.

### Examples

- Replace random naming with fixed names in basic/complete/secure.
- Add a permissions example that references the module-created endpoint by default (no explicit ID).
- Show module-level `for_each` for multiple endpoints in complete.
- Ensure examples are self-contained and runnable.

### Tests

Update per TESTING_GUIDE:
- Unit: key uniqueness, permission lookup validation, and auth-mode validations (GitHub, Kubernetes, OpenShift, SSH, AWS).
- Integration: create a generic endpoint and permissions that resolve to the module endpoint by default.
- Negative: invalid auth combinations and missing permission targets.

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-serviceendpoint-refactor.md`

## Acceptance Criteria

- Module manages a single service endpoint per instance (non-iterated).
- Permissions use stable keys with uniqueness validation.
- `serviceendpoint_permissions` can resolve module-created endpoints or accept explicit IDs with validation.
- Sensitive values are marked as `sensitive`.
- Examples use fixed names and include a permissions workflow.
- `docs/IMPORT.md` added.
- Unit + integration + negative tests updated and passing.

## Implementation Checklist

- [ ] Refactor variables.tf: replace endpoint lists with a single endpoint object; add validations and mark sensitive fields.
- [ ] Refactor main.tf: remove endpoint `for_each`, keep stable keys for permissions, add default endpoint resolution.
- [ ] Refactor outputs.tf: single endpoint outputs and permissions output.
- [ ] Update examples and fixtures: fixed names and permissions referencing module endpoints.
- [ ] Add docs/IMPORT.md.
- [ ] Update tests (unit, fixtures, terratest, test_config).
- [ ] make docs + update README.
