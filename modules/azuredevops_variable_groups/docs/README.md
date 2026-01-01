# Azure DevOps Variable Groups Module Documentation

## Overview

This module manages Azure DevOps variable groups resources and related configuration.

## Managed Resources

- `azuredevops_library_permissions`
- `azuredevops_variable_group`
- `azuredevops_variable_group_permissions`

## Usage Notes

- Requires `project_id` for project scoping.
- Use `git::https://...//modules/azuredevops_variable_groups?ref=ADOVGvX.Y.Z` for module source.
- Optional child resources are created only when corresponding inputs are set.
- Use stable keys and unique names for list/object inputs to avoid address churn.

## Inputs (Highlights)

- Required: `name`, `project_id`, `variables`
- Optional: see `../README.md` and `../variables.tf`.

## Outputs (Highlights)

- `variable_group_id`
- `variable_group_name`

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
