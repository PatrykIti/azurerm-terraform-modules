# Azure DevOps Agent Pools Module Documentation

## Overview

This module manages Azure DevOps agent pools resources and related configuration.

## Managed Resources

- `azuredevops_agent_pool`
- `azuredevops_elastic_pool`

## Usage Notes

- Use `git::https://...//modules/azuredevops_agent_pools?ref=ADOAPvX.Y.Z` for module source.
- Optional child resources are created only when corresponding inputs are set.
- Agent queues are project-scoped; manage them in the Azure DevOps project module.

## Inputs (Highlights)

- Required: `name`
- Optional: see `../README.md` and `../variables.tf`.

## Outputs (Highlights)

- `agent_pool_id`
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
