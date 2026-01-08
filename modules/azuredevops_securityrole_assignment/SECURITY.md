# azuredevops_securityrole_assignment Module Security

## Overview

This module manages Azure DevOps security role assignments. Use least privilege and stable identity IDs.

## Security Features

- Requires explicit identity IDs for every assignment.
- Validates scope, resource, and role names are non-empty.

## Security Configuration Example

```hcl
module "azuredevops_securityrole_assignment" {
  source = "./modules/azuredevops_securityrole_assignment"

  scope       = "<scope_id>"
  resource_id = "<resource_id>"
  role_name   = "Reader"
  identity_id = "11111111-1111-1111-1111-111111111111"
}
```

## Security Hardening Checklist

- [ ] Use least-privilege roles for each scope.
- [ ] Review assignments regularly and remove unused identities.
- [ ] Track changes through PR reviews and approvals.

## Common Security Mistakes to Avoid

1. Over-privileging shared identities.
2. Leaving stale assignments active.
3. Reusing broad roles where least-privilege would be sufficient.

---

**Module Version**: 0.1.0  
**Last Updated**: 2026-01-08  
**Security Contact**: patryk.ciechanski@patrykiti.pl
