# Azure DevOps Identity Module Documentation

## Overview

This module manages Azure DevOps identity resources and related configuration.

## Managed Resources

- `azuredevops_group`
- `azuredevops_group_entitlement`
- `azuredevops_group_membership`
- `azuredevops_securityrole_assignment`
- `azuredevops_service_principal_entitlement`
- `azuredevops_user_entitlement`

## Usage Notes

- Use `git::https://...//modules/azuredevops_identity?ref=ADOIvX.Y.Z` for module source.
- Optional child resources are created only when corresponding inputs are set.
- Use stable keys and unique names for list/object inputs to avoid address churn.

## Inputs (Highlights)

- Required: None.
- Optional: see `../README.md` and `../variables.tf`.

## Outputs (Highlights)

- `group_descriptor`
- `group_entitlement_descriptors`
- `group_entitlement_ids`
- `group_id`
- `group_membership_ids`
- `securityrole_assignment_ids`
- `service_principal_entitlement_descriptors`
- `service_principal_entitlement_ids`
- `user_entitlement_descriptors`
- `user_entitlement_ids`

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
