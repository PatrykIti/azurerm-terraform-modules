# Role Definition Module Documentation

## Overview

The `azurerm_role_definition` module manages a single custom Azure RBAC role
definition. It is atomic and does not create scopes or role assignments.

## Managed Resources

- `azurerm_role_definition`

## Out of Scope

- Role assignments (use the role assignment module)
- Creating scopes (management groups, subscriptions, resource groups, resources)
- Creating principals (users, groups, service principals, managed identities)

## Usage Notes

- `permissions` must include at least one `actions` or `data_actions` entry.
- `assignable_scopes` must be within the provided `scope` and cannot be empty.
- Data actions are not supported at management group scope.

## Additional References

- See `SECURITY.md` for least-privilege guidance.
- See `IMPORT.md` for import instructions.
