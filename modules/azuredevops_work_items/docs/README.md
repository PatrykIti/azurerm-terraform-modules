# Azure DevOps Work Items Module Documentation

## Overview

This module manages Azure DevOps azure devops work items resources and related configuration.

## Managed Resources

- `azuredevops_area_permissions`
- `azuredevops_iteration_permissions`
- `azuredevops_tagging_permissions`
- `azuredevops_workitem`
- `azuredevops_workitemquery`
- `azuredevops_workitemquery_folder`
- `azuredevops_workitemquery_permissions`
- `azuredevops_workitemtrackingprocess_process`

## Usage Notes

- Use `git::https://...//modules/azuredevops_work_items?ref=ADOWKvX.Y.Z` for module source.
- Optional child resources are created only when corresponding inputs are set.
- Use stable keys and unique names for list/object inputs to avoid address churn.

## Inputs (Highlights)

- Required: `title`, `type`
- Optional: see `../README.md` and `../variables.tf`.

## Outputs (Highlights)

- `area_permission_ids`
- `iteration_permission_ids`
- `process_ids`
- `query_folder_ids`
- `query_ids`
- `query_permission_ids`
- `tagging_permission_ids`
- `work_item_id`

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
