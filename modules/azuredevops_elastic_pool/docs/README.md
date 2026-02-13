# Azure DevOps Elastic Pool Module Documentation

## Overview

This module manages a single Azure DevOps elastic pool.

## Managed Resources

- `azuredevops_elastic_pool`

## Usage Notes

- Use `git::https://...//modules/azuredevops_elastic_pool?ref=ADOEPvX.Y.Z` for module source.
- This module is intentionally atomic and manages only the elastic pool resource.

## Inputs (Highlights)

- Required: `name`, `service_endpoint_id`, `service_endpoint_scope`, `azure_resource_id`
- Optional: `desired_idle`, `max_capacity`, `recycle_after_each_use`, `time_to_live_minutes`, `agent_interactive_ui`, `auto_provision`, `auto_update`, `project_id`

## Outputs (Highlights)

- `elastic_pool_id`

## Import Existing Resources

See [IMPORT.md](./IMPORT.md) for import blocks and IDs.

## Troubleshooting

- **Permission errors**: ensure the PAT has rights for elastic pool operations.
- **Plan drift**: align elastic pool settings with existing state.

## Related Docs

- [README.md](../README.md) - module usage and inputs/outputs
- [IMPORT.md](./IMPORT.md) - import guide
- [VERSIONING.md](../VERSIONING.md) - tag format and release flow
- [SECURITY.md](../SECURITY.md) - security guidance
- [CONTRIBUTING.md](../CONTRIBUTING.md) - contribution rules
