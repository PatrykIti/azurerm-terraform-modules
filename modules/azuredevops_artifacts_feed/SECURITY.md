# azuredevops_artifacts_feed Module Security

## Overview

This document describes security considerations for Azure DevOps Artifacts feeds managed with Terraform.

## Security Features

### 1. Access Control
- Use feed permissions to grant least-privilege access.
- Avoid assigning administrator role to broad groups.

### 2. Retention Policies
- Configure retention policies to reduce exposure of outdated packages.
- Limit package versions with count and age thresholds.

### 3. Scope Selection
- Prefer project-scoped feeds when organization-wide access is not required.

## Security Configuration Example

```hcl
module "azuredevops_artifacts_feed" {
  source = "./modules/azuredevops_artifacts_feed"

  name       = "secure-feed"
  project_id = "00000000-0000-0000-0000-000000000000"

  feed_permissions = [
    {
      identity_descriptor = "vssgp.Uy0xLTktMTIzNDU2"
      role                = "reader"
    }
  ]

  feed_retention_policies = [
    {
      count_limit                               = 10
      days_to_keep_recently_downloaded_packages = 30
    }
  ]
}
```

## Security Hardening Checklist

- [ ] Limit feed access to required roles only.
- [ ] Use project-level feeds when possible.
- [ ] Enforce retention policies to remove stale packages.
- [ ] Review feed permissions on a regular cadence.

## Common Security Mistakes to Avoid

1. **Granting administrator access to all users**
2. **Leaving organization-level feeds open**
3. **Skipping retention policies for sensitive packages**

## Additional Resources

- [Azure DevOps Artifacts Feeds](https://learn.microsoft.com/en-us/azure/devops/artifacts/feeds)
- [Azure DevOps Permissions](https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions)

---

**Module Version**: 1.0.0  
**Last Updated**: 2025-12-28  
**Security Contact**: security@yourorganization.com
