# Azure DevOps Artifacts Feed Module Documentation

## Overview

This module manages Azure DevOps azure devops artifacts feed resources and related configuration.

## Managed Resources

- `azuredevops_feed`
- `azuredevops_feed_permission`
- `azuredevops_feed_retention_policy`

## Usage Notes

- Use `git::https://...//modules/azuredevops_artifacts_feed?ref=ADOAFvX.Y.Z` for module source.
- Optional child resources are created only when corresponding inputs are set.
- Use stable keys and unique names for list/object inputs to avoid address churn.

## Inputs (Highlights)

- Required: None.
- Optional: see `../README.md` and `../variables.tf`.

## Outputs (Highlights)

- `feed_id`
- `feed_name`
- `feed_permission_ids`
- `feed_project_id`
- `feed_retention_policy_ids`

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
