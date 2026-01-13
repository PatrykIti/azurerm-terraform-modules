# Azure DevOps Group Module Documentation

## Overview

This module manages Azure DevOps groups with memberships and group entitlements.

## Managed Resources

- `azuredevops_group`
- `azuredevops_group_entitlement`
- `azuredevops_group_membership`

## Usage Notes

- Use `git::https://...//modules/azuredevops_group?ref=ADOGvX.Y.Z` for module source.
- Optional child resources are created only when corresponding inputs are set.
- Use stable keys and unique names for list/object inputs to avoid address churn.

## Inputs (Highlights)

- Required: exactly one of `group_display_name`, `group_origin_id`, or `group_mail`.
- `group_scope` is valid only when `group_display_name` is set.
- Optional: see `../README.md` and `../variables.tf`.

## Outputs (Highlights)

- `group_descriptor`
- `group_entitlement_descriptors`
- `group_entitlement_ids`
- `group_id`
- `group_membership_ids`

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
