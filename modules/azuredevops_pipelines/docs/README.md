# Azure DevOps Pipelines Module Documentation

## Overview

This module manages Azure DevOps azure devops pipelines resources and related configuration.

## Managed Resources

- `azuredevops_build_definition`
- `azuredevops_build_definition_permissions`
- `azuredevops_build_folder`
- `azuredevops_build_folder_permissions`
- `azuredevops_pipeline_authorization`

## Usage Notes

- Requires `project_id` for project scoping.
- Use `git::https://...//modules/azuredevops_pipelines?ref=ADOPIvX.Y.Z` for module source.
- Optional child resources are created only when corresponding inputs are set.
- Use stable keys and unique names for list/object inputs to avoid address churn.

## Inputs (Highlights)

- Required: `name`, `project_id`, `repository`
- Optional: see `../README.md` and `../variables.tf`.

## Outputs (Highlights)

- `build_definition_id`
- `build_folder_ids`

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
