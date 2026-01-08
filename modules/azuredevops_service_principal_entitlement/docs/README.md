# Azure DevOps Service Principal Entitlement Module Documentation

## Overview

This module manages Azure DevOps service principal entitlements.

## Managed Resources

- `azuredevops_service_principal_entitlement`

## Usage Notes

- Use `git::https://...//modules/azuredevops_service_principal_entitlement?ref=ADOSPEvX.Y.Z` for module source.
- This module manages a single entitlement resource; iterate in the consuming configuration when you need multiple service principals.

## Inputs (Highlights)

- Required: `origin_id`
- Optional: see `../README.md` and `../variables.tf`.

## Outputs (Highlights)

- `service_principal_entitlement_id`
- `service_principal_entitlement_descriptor`

## Import Existing Resources

See [IMPORT.md](./IMPORT.md) for import blocks and IDs.

## Troubleshooting

- **Permission errors**: ensure the PAT has rights for entitlement operations.
- **Plan drift**: align inputs with existing state or leave optional inputs unset.

## Related Docs

- [README.md](../README.md) - module usage and inputs/outputs
- [IMPORT.md](./IMPORT.md) - import guide
- [VERSIONING.md](../VERSIONING.md) - tag format and release flow
- [SECURITY.md](../SECURITY.md) - security guidance
- [CONTRIBUTING.md](../CONTRIBUTING.md) - contribution rules
