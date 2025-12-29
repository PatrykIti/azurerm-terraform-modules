# azuredevops_team Module Security

## Overview

This document describes security considerations for Azure DevOps teams managed by Terraform. The module focuses on team creation, membership, and administrator assignments.

## Security Features

### 1. Membership Management
- Use group descriptors for team membership where possible.
- Avoid direct user assignments unless required.

### 2. Administrator Assignments
- Limit administrators to the minimum required set.
- Separate admin roles from general membership.

### 3. Auditability
- Changes are tracked via Terraform state and version control.
- Use pull requests for access changes.

## Security Configuration Example

```hcl
module "azuredevops_team" {
  source = "./modules/azuredevops_team"

  project_id  = "00000000-0000-0000-0000-000000000000"
  name        = "ado-platform"
  description = "Platform engineering team"

  team_administrators = [
    {
      key               = "platform-admins"
      admin_descriptors = ["vssgp.Uy0xLTktMTIzNDU2Nzg5MA"]
      mode              = "add"
    }
  ]
}
```

## Security Hardening Checklist

- [ ] Manage team membership through groups.
- [ ] Keep administrator lists short and reviewed.
- [ ] Avoid overwrite mode unless intended for strict control.
- [ ] Review descriptors and access changes regularly.

## Common Security Mistakes to Avoid

1. **Assigning large groups as admins**
2. **Using overwrite mode without change review**
3. **Granting direct user access for broad teams**

## Additional Resources

- [Azure DevOps Security Documentation](https://learn.microsoft.com/en-us/azure/devops/organizations/security/about-security-identity?view=azure-devops)
- [Azure DevOps Permissions and Access Levels](https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions?view=azure-devops)

---

**Module Version**: 1.0.0  
**Last Updated**: 2025-12-28  
**Security Contact**: patryk.ciechanski@patrykiti.pl
