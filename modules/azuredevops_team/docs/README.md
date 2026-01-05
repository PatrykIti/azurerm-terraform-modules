# Azure DevOps Team Module Documentation

## Overview

This module manages Azure DevOps team resources and related configuration.

## Managed Resources

- `azuredevops_team`
- `azuredevops_team_administrators`
- `azuredevops_team_members`

## Usage Notes

- Requires `project_id` for project scoping.
- Use `git::https://...//modules/azuredevops_team?ref=ADOTvX.Y.Z` for module source.
- Optional child resources are created only when corresponding inputs are set.
- Use stable keys and unique names for list/object inputs to avoid address churn.

## Inputs (Highlights)

- Required: `name`, `project_id`
- Optional: see `../README.md` and `../variables.tf`.

## Outputs (Highlights)

- `team_administrator_ids`
- `team_descriptor`
- `team_id`
- `team_member_ids`

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
