# Azure DevOps Extension Module Documentation

## Overview

This module manages Azure DevOps extension resources and related configuration.

## Managed Resources

- `azuredevops_extension`

## Usage Notes

- Use `git::https://...//modules/azuredevops_extension?ref=ADOEXvX.Y.Z` for module source.
- For multiple extensions, use module-level `for_each` with stable keys (for example, `publisher_id/extension_id`).

## Inputs (Highlights)

- Required: `extension_id`, `publisher_id`
- Optional: see `../README.md` and `../variables.tf`.

## Outputs (Highlights)

- `extension_id`

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
