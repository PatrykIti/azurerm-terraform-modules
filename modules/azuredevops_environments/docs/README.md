# Azure DevOps Environments Module Documentation

## Overview

This module manages Azure DevOps environments resources and related configuration.

## Managed Resources

- `azuredevops_check_approval`
- `azuredevops_check_branch_control`
- `azuredevops_check_business_hours`
- `azuredevops_check_exclusive_lock`
- `azuredevops_check_required_template`
- `azuredevops_check_rest_api`
- `azuredevops_environment`
- `azuredevops_environment_resource_kubernetes`

## Usage Notes

- Requires `project_id` for project scoping.
- Use `git::https://...//modules/azuredevops_environments?ref=ADOEvX.Y.Z` for module source.
- Environment checks are configured via root `check_*` inputs.
- Kubernetes environment resources do not support approvals and checks.
- Optional child resources are created only when corresponding inputs are set.
- Use stable names and unique names per list to avoid address churn.

## Inputs (Highlights)

- Required: `name`, `project_id`
- Optional: see `../README.md` and `../variables.tf`.

## Outputs (Highlights)

- `check_ids`
- `environment_id`
- `kubernetes_resource_ids`

## Import Existing Resources

See [IMPORT.md](./IMPORT.md) for import blocks and IDs.

## Troubleshooting

- **Permission errors**: ensure the PAT has rights for the target resource scope.
- **Plan drift**: align inputs with existing state or leave optional inputs unset.
- **Duplicate keys**: ensure list/object inputs use unique keys or names.

## Related Docs

- [README.md](../README.md) - module usage and inputs/outputs
- [IMPORT.md](./IMPORT.md) - import guide
- [VERSIONING.md](../VERSIONING.md) - tag format and release flow
- [SECURITY.md](../SECURITY.md) - security guidance
- [CONTRIBUTING.md](../CONTRIBUTING.md) - contribution rules
