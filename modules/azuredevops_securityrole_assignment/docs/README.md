# Azure DevOps Security Role Assignment Module Documentation

## Overview

This module manages Azure DevOps security role assignments.

## Managed Resources

- `azuredevops_securityrole_assignment`

## Usage Notes

- Use `git::https://...//modules/azuredevops_securityrole_assignment?ref=ADOSRAvX.Y.Z` for module source.
- Use stable identity and resource IDs to avoid plan drift.

## Inputs (Highlights)

- Required: `identity_id`, `scope`, `resource_id`, `role_name`
- Optional: see `../README.md` and `../variables.tf`.

## Outputs (Highlights)

- `securityrole_assignment_id`

## Import Existing Resources

See [IMPORT.md](./IMPORT.md) for import blocks and IDs.

## Troubleshooting

- **Permission errors**: ensure the PAT has rights for assignments.
- **Plan drift**: align inputs with existing state and use stable identity IDs.
- **Invalid IDs**: verify `resource_id` and `identity_id` from Azure DevOps APIs.

## Related Docs

- [README.md](../README.md) - module usage and inputs/outputs
- [IMPORT.md](./IMPORT.md) - import guide
- [VERSIONING.md](../VERSIONING.md) - tag format and release flow
- [SECURITY.md](../SECURITY.md) - security guidance
- [CONTRIBUTING.md](../CONTRIBUTING.md) - contribution rules
