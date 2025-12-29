# azuredevops_work_items Module Security

## Overview

This document describes security considerations for Azure DevOps work items and permissions managed with Terraform.

## Security Features

### 1. Permissions Management
- Apply permissions to groups rather than individual users.
- Restrict tagging, area, and iteration permissions to trusted teams.

### 2. Query Access
- Use query permissions to control visibility of shared queries.
- Avoid granting manage permissions broadly.

### 3. Process Governance
- Limit process creation and customization to administrators.

## Security Configuration Example

```hcl
module "azuredevops_work_items" {
  source = "./modules/azuredevops_work_items"

  project_id = "00000000-0000-0000-0000-000000000000"

  title = "Secure Work Item"
  type  = "Issue"

  query_permissions = [
    {
      principal = "vssgp.Uy0xLTktMTIzNDU2"
      permissions = {
        Read              = "Allow"
        Contribute        = "Deny"
        ManagePermissions = "Deny"
        Delete            = "Deny"
      }
    }
  ]

  tagging_permissions = [
    {
      principal = "vssgp.Uy0xLTktMTIzNDU2"
      permissions = {
        Enumerate = "allow"
        Create    = "deny"
        Update    = "deny"
        Delete    = "deny"
      }
    }
  ]
}
```

## Security Hardening Checklist

- [ ] Restrict work item permissions to group principals.
- [ ] Control query access to shared queries.
- [ ] Apply least-privilege for tagging and area permissions.
- [ ] Review process customization access regularly.

## Common Security Mistakes to Avoid

1. **Granting manage permissions to broad groups**
2. **Allowing unrestricted tagging across projects**
3. **Exposing sensitive queries to all users**

## Additional Resources

- [Azure DevOps Work Items](https://learn.microsoft.com/en-us/azure/devops/boards/work-items/about-work-items)
- [Azure DevOps Permissions](https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions)

---

**Module Version**: 1.0.0  
**Last Updated**: 2025-12-24  
**Security Contact**: security@yourorganization.com
