# Azure DevOps Agent Pools Module Documentation

## Overview

This module manages Azure DevOps azure devops agent pools resources and related configuration.

## Managed Resources

- `azuredevops_agent_pool`
- `azuredevops_agent_queue`
- `azuredevops_elastic_pool`

## Usage Notes

- Use `git::https://...//modules/azuredevops_agent_pools?ref=ADOAPvX.Y.Z` for module source.
- Optional child resources are created only when corresponding inputs are set.
- Use stable keys and unique names for list/object inputs to avoid address churn.

## Inputs (Highlights)

- Required: `name`
- Optional: see `../README.md` and `../variables.tf`.

## Outputs (Highlights)

- `agent_pool_id`
- `agent_queue_ids`
- `elastic_pool_id`

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
