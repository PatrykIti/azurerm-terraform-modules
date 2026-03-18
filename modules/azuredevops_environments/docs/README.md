# Azure DevOps Environments Module Documentation

## Overview

This module manages one Azure DevOps environment and optional child resources:

- Kubernetes environment resources (`azuredevops_environment_resource_kubernetes`)
- Environment-level checks (`check_*` root inputs)
- Kubernetes-resource checks (`kubernetes_resources[*].checks`)

## Targeting Model

- Root `check_*` inputs always target the module-managed environment (`target_resource_type = "environment"`).
- Nested checks under `kubernetes_resources[*].checks` target the Kubernetes backing service endpoint (`target_resource_type = "endpoint"`).
  This is required because the Azure DevOps provider supports check targets: `endpoint`, `environment`, `queue`, `repository`, `securefile`, `variablegroup`.
- External `target_resource_id` / `target_resource_type` inputs are intentionally not exposed.

## Managed Resources

- `azuredevops_environment`
- `azuredevops_environment_resource_kubernetes`
- `azuredevops_check_approval` (environment and kubernetes-endpoint scoped)
- `azuredevops_check_branch_control` (environment and kubernetes-endpoint scoped)
- `azuredevops_check_business_hours` (environment and kubernetes-endpoint scoped)
- `azuredevops_check_exclusive_lock` (environment and kubernetes-endpoint scoped)
- `azuredevops_check_required_template` (environment and kubernetes-endpoint scoped)
- `azuredevops_check_rest_api` (environment and kubernetes-endpoint scoped)

## Input Rules

- `name` fields are required and validated for all checks.
- Check names must be unique within each list.
- `kubernetes_resources[*].name` values must be unique.
- Structured inputs use `object` / `list(object)` with validation for early failures.

## Outputs

- `environment_id`
- `kubernetes_resource_ids`
- `check_ids`

`check_ids` is grouped by:
- `environment`
- `kubernetes_resources[resource_name]`

## Import Existing Resources

See [IMPORT.md](./IMPORT.md).

## Related Docs

- [README.md](../README.md)
- [SECURITY.md](../SECURITY.md)
- [VERSIONING.md](../VERSIONING.md)
- [CONTRIBUTING.md](../CONTRIBUTING.md)
