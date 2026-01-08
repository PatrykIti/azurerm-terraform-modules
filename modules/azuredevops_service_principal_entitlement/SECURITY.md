# azuredevops_service_principal_entitlement Module Security

## Overview

This module manages Azure DevOps service principal entitlements. Keep entitlements minimal and scoped.

## Security Features

- Enforces explicit `origin_id` for each service principal.
- Validates license types and licensing sources.
- Stable keys avoid accidental address churn.

## Security Configuration Example

```hcl
module "azuredevops_service_principal_entitlement" {
  source = "./modules/azuredevops_service_principal_entitlement"

  origin_id            = "00000000-0000-0000-0000-000000000000"
  account_license_type = "basic"
  licensing_source     = "account"
}
```

## Security Hardening Checklist

- [ ] Grant the lowest license required for the service principal.
- [ ] Review entitlements regularly and remove stale identities.
- [ ] Track changes through PR reviews and approvals.

## Common Security Mistakes to Avoid

1. Assigning high-privilege licenses to broadly used service principals.
2. Leaving unused service principals licensed.
3. Reusing the same service principal entitlement across multiple configs without coordination.

---

**Module Version**: 0.1.0  
**Last Updated**: 2025-12-28  
**Security Contact**: patryk.ciechanski@patrykiti.pl
