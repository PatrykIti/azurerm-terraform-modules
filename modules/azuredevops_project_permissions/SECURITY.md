# azuredevops_project_permissions Module Security

## Overview

This document describes security considerations for the Azure DevOps project permissions module. The module manages project-level permissions for group principals.

## Secure Example

See the hardened baseline in `examples/secure`, which focuses on least-privilege permissions.

## Security Features

### 1. Group-Only Assignment
- Permissions are assigned to groups, not individual users.
- Use group membership (e.g., via the identity module) to manage user access.

### 2. Least Privilege
- Grant only required permissions for each group.
- Prefer `NotSet` or `Deny` for sensitive permissions unless explicitly needed.

### 3. Controlled Overrides
- Use `principal` only when the group descriptor is known and stable.
- Prefer `group_name` + `scope` to avoid hardcoding descriptors.

## Security Configuration Example

```hcl
module "azuredevops_project_permissions" {
  source = "./modules/azuredevops_project_permissions"

  project_id = var.project_id

  permissions = [
    {
      key        = "readers"
      group_name = "Readers"
      scope      = "project"
      permissions = {
        GENERIC_READ = "Allow"
      }
      replace = false
    }
  ]
}
```

## Security Hardening Checklist

- [ ] Assign permissions only to groups, not individuals.
- [ ] Limit write/admin permissions to a small set of groups.
- [ ] Use `replace = false` unless you intentionally want to reset permissions.
- [ ] Review permissions regularly and remove unused entries.

## Common Security Mistakes to Avoid

1. **Assigning broad permissions to large groups**
2. **Using hardcoded descriptors without documentation**
3. **Replacing permissions unintentionally**

## Additional Resources

- [Azure DevOps Security Documentation](https://learn.microsoft.com/en-us/azure/devops/organizations/security/about-security-identity?view=azure-devops)
- [Azure DevOps Permissions Reference](https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions?view=azure-devops)

---

**Module Version**: 1.0.0  
**Last Updated**: 2025-12-25  
**Security Contact**: patryk.ciechanski@patrykiti.pl
