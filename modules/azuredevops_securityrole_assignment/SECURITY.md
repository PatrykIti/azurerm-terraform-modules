# azuredevops_securityrole_assignment Module Security

## Overview

This module manages Azure DevOps security role assignments. Use least privilege and stable keys.

## Security Features

- Requires explicit identity IDs for every assignment.
- Validates scope, resource, and role names are non-empty.
- Enforces unique keys per assignment to avoid accidental overwrites.

## Security Configuration Example

```hcl
module "azuredevops_securityrole_assignment" {
  source = "./modules/azuredevops_securityrole_assignment"

  securityrole_assignments = [
    {
      key         = "project-reader"
      scope       = "project"
      resource_id = "00000000-0000-0000-0000-000000000000"
      role_name   = "Reader"
      identity_id = "11111111-1111-1111-1111-111111111111"
    }
  ]
}
```

## Security Hardening Checklist

- [ ] Use least-privilege roles for each scope.
- [ ] Review assignments regularly and remove unused identities.
- [ ] Track changes through PR reviews and approvals.

## Common Security Mistakes to Avoid

1. Over-privileging shared identities.
2. Leaving stale assignments active.
3. Using non-deterministic keys that cause address churn.

---

**Module Version**: 0.1.0  
**Last Updated**: 2025-12-28  
**Security Contact**: patryk.ciechanski@patrykiti.pl
