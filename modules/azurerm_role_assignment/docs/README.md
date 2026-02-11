# Role Assignment Module Documentation

## Overview

The `azurerm_role_assignment` module manages a single Azure RBAC role assignment.
It is atomic and does not create principals or scopes; those must be supplied as
IDs. The module focuses on safe defaults and explicit configuration.

## Managed Resources

- `azurerm_role_assignment`

## Out of Scope

- Creating or looking up principals (users, groups, service principals, managed identities)
- Creating scopes (management groups, subscriptions, resource groups, resources)
- PIM / eligibility schedules / role management policies
- Networking glue, private endpoints, diagnostic settings, or monitoring

## Usage Notes

- Exactly one of `role_definition_id` or `role_definition_name` must be set.
- Use `principal_type` explicitly when enabling `skip_service_principal_aad_check`.
- `condition` requires `condition_version = "2.0"`.
- `delegated_managed_identity_resource_id` is intended for cross-tenant scenarios.

## Additional References

- See `SECURITY.md` for risk guidance and least-privilege recommendations.
- See `IMPORT.md` for import instructions.
