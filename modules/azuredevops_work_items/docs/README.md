# Azure DevOps Work Items Module Documentation

## Overview

This module manages a single `azuredevops_workitem` resource per module instance.

## Managed Resources

- `azuredevops_workitem`

## Usage Notes

- Use module-level `for_each` in consumer code to manage multiple work items.
- Cross-scope resources (processes, queries, and query/area/iteration/tagging permissions) are intentionally out of scope for this atomic module.
- Requires `project_id`, `title`, and `type`.

## Outputs (Highlights)

- `work_item_id`

## Import Existing Resources

See [IMPORT.md](./IMPORT.md) for import blocks and IDs.

## Related Docs

- [README.md](../README.md) - module usage and inputs/outputs
- [IMPORT.md](./IMPORT.md) - import guide
- [VERSIONING.md](../VERSIONING.md) - tag format and release flow
- [SECURITY.md](../SECURITY.md) - security guidance
- [CONTRIBUTING.md](../CONTRIBUTING.md) - contribution rules
