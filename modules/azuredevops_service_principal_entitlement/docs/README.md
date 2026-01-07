# Azure DevOps Service Principal Entitlement Module Documentation

## Overview

This module manages Azure DevOps service principal entitlements.

## Managed Resources

- `azuredevops_service_principal_entitlement`

## Usage Notes

- Use `git::https://...//modules/azuredevops_service_principal_entitlement?ref=ADOSPEvX.Y.Z` for module source.
- Use stable keys and unique names for list/object inputs to avoid address churn.

## Inputs (Highlights)

- Required: `service_principal_entitlements.origin_id`
- Optional: see `../README.md` and `../variables.tf`.

## Outputs (Highlights)

- `service_principal_entitlement_ids`
- `service_principal_entitlement_descriptors`

## Import Existing Resources

See [IMPORT.md](./IMPORT.md) for import blocks and IDs.

## Troubleshooting

- **Permission errors**: ensure the PAT has rights for entitlement operations.
- **Plan drift**: align inputs with existing state or leave optional inputs unset.
- **Duplicate keys**: ensure list/object inputs use unique keys or names.

## Related Docs

- [README.md](../README.md) - module usage and inputs/outputs
- [IMPORT.md](./IMPORT.md) - import guide
- [VERSIONING.md](../VERSIONING.md) - tag format and release flow
- [SECURITY.md](../SECURITY.md) - security guidance
- [CONTRIBUTING.md](../CONTRIBUTING.md) - contribution rules
