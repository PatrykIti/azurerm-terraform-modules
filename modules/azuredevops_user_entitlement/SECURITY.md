# azuredevops_user_entitlement Module Security

## Overview

This module manages Azure DevOps user entitlements. Keep entitlements minimal and scoped.

## Security Features

- Requires explicit `principal_name` or `origin_id` for each user.
- Validates license types and licensing sources.
- Stable keys avoid accidental address churn.

## Security Configuration Example

```hcl
module "azuredevops_user_entitlement" {
  source = "./modules/azuredevops_user_entitlement"

  user_entitlements = [
    {
      key                  = "platform-user"
      principal_name       = "user@example.com"
      account_license_type = "basic"
      licensing_source     = "account"
    }
  ]
}
```

## Security Hardening Checklist

- [ ] Grant the lowest license required for the user.
- [ ] Review entitlements regularly and remove stale identities.
- [ ] Track changes through PR reviews and approvals.

## Common Security Mistakes to Avoid

1. Assigning high-privilege licenses to broadly used users.
2. Leaving unused users licensed.
3. Reusing the same key across different entitlements.

---

**Module Version**: 0.1.0  
**Last Updated**: 2025-12-28  
**Security Contact**: patryk.ciechanski@patrykiti.pl
