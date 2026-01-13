# Azure DevOps User Entitlement Module Documentation

## Overview

This module manages Azure DevOps user entitlements.

## Managed Resources

- `azuredevops_user_entitlement`

## Usage Notes

- Use `git::https://...//modules/azuredevops_user_entitlement?ref=ADOUvX.Y.Z` for module source.
- The module manages a single entitlement; iterate with `for_each` on the module when managing multiple users.
- Use stable keys when iterating to avoid address churn.

## Inputs (Highlights)

- Required: either `user_entitlement.principal_name` or `user_entitlement.origin` + `user_entitlement.origin_id`.
- Derived key uses `user_entitlement.key`, falling back to `principal_name` or `origin_id` when not set.
- Optional: see `../README.md` and `../variables.tf`.

## Outputs (Highlights)

- `user_entitlement_id`
- `user_entitlement_descriptor`
- `user_entitlement_key`

## Import Existing Resources

See [IMPORT.md](./IMPORT.md) for import blocks and IDs.

## Troubleshooting

- **Permission errors**: ensure the PAT has rights for entitlement operations.
- **Plan drift**: align inputs with existing state or leave optional inputs unset.
- **Duplicate keys**: ensure module `for_each` keys are unique when iterating.

## Related Docs

- [README.md](../README.md) - module usage and inputs/outputs
- [IMPORT.md](./IMPORT.md) - import guide
- [VERSIONING.md](../VERSIONING.md) - tag format and release flow
- [SECURITY.md](../SECURITY.md) - security guidance
- [CONTRIBUTING.md](../CONTRIBUTING.md) - contribution rules
