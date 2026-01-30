# azurerm_role_definition Module Security

## Overview

This module manages a single **custom** Azure RBAC role definition. Security
risk is driven by the actions you allow and the scopes where the role can be
assigned.

## Security Considerations

### Least Privilege
- Grant only the actions required for the workload.
- Avoid wildcards (`*`) and broad management actions.

### Assignable Scopes
- Keep `assignable_scopes` as narrow as possible.
- Prefer resource group scope over subscription or management group scope.

### Data Actions
- Data actions grant access to data plane operations.
- Data actions are **not supported** at management group scope.

## Example: Minimal Role

```hcl
module "role_definition" {
  source = "./modules/azurerm_role_definition"

  name  = "rg-readonly"
  scope = azurerm_resource_group.example.id

  permissions = [
    {
      actions = [
        "Microsoft.Resources/subscriptions/resourceGroups/read"
      ]
    }
  ]

  assignable_scopes = [
    azurerm_resource_group.example.id
  ]
}
```

## Hardening Checklist

- [ ] Avoid broad scopes unless required
- [ ] Keep `actions` minimal and explicit
- [ ] Avoid data actions unless necessary
- [ ] Review custom roles regularly

---

**Last Updated**: 2026-01-30
