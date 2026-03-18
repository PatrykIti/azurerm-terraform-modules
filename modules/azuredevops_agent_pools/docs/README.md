# Azure DevOps Agent Pools Module Documentation

## Overview

This module manages a single Azure DevOps agent pool.

## Managed Resources

- `azuredevops_agent_pool`

## Usage Notes

- Use `git::https://...//modules/azuredevops_agent_pools?ref=ADOAPvX.Y.Z` for module source.
- This module is intentionally atomic and manages only the pool resource.
- Elastic pool scope is managed by `modules/azuredevops_elastic_pool`.

## Inputs (Highlights)

- Required: `name`
- Optional: `auto_provision`, `auto_update`, `pool_type`

## Outputs (Highlights)

- `agent_pool_id`

## Import Existing Resources

See [IMPORT.md](./IMPORT.md) for import blocks and IDs.

## Troubleshooting

- **Permission errors**: ensure the PAT has rights for the target organization scope.
- **Plan drift**: align inputs with existing state.

## Related Docs

- [README.md](../README.md) - module usage and inputs/outputs
- [IMPORT.md](./IMPORT.md) - import guide
- [VERSIONING.md](../VERSIONING.md) - tag format and release flow
- [SECURITY.md](../SECURITY.md) - security guidance
- [CONTRIBUTING.md](../CONTRIBUTING.md) - contribution rules
