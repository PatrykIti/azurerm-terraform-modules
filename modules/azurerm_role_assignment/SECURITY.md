# azurerm_role_assignment Module Security

## Overview

This module manages a single Azure RBAC role assignment. Security risks are
primarily driven by **role choice** and **scope size**. The module does not
create principals or scopes; you must supply them explicitly.

## Security Considerations

### Least Privilege
- Prefer narrowly scoped roles and resource-group or resource-level scopes.
- Avoid broad roles like **Owner** and **Contributor** unless absolutely required.
- Limit custom roles to the minimum set of actions.

### Scope Size
- Assignments at management group or subscription scope are high impact.
- Use resource group or resource scopes where feasible.

### ABAC Conditions
- `condition` and `condition_version = "2.0"` enable attribute-based access control.
- Conditions reduce blast radius but must be tested carefully.

### Service Principal AAD Check
- `skip_service_principal_aad_check` skips AAD consistency checks.
- Use only when assigning roles to **service principals** that were just created.
- Do not enable unless you understand the propagation trade-offs.

### Delegated Managed Identity
- `delegated_managed_identity_resource_id` is intended for cross-tenant scenarios.
- Avoid unless you are explicitly delegating access between tenants.

## Example: Least-Privilege Assignment

```hcl
module "role_assignment" {
  source = "./modules/azurerm_role_assignment"

  scope                = azurerm_resource_group.example.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.example.principal_id
  principal_type       = "ServicePrincipal"
  description          = "Read-only access for workload identity"
}
```

## Hardening Checklist

- [ ] Use the smallest practical scope
- [ ] Avoid Owner/Contributor unless required
- [ ] Prefer custom roles with explicit actions
- [ ] Use ABAC conditions when feasible
- [ ] Avoid `skip_service_principal_aad_check` unless required

---

**Last Updated**: 2026-01-30
