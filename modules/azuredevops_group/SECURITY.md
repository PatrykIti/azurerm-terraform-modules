# azuredevops_group Module Security

## Overview

This document describes security considerations for managing Azure DevOps groups and memberships via Terraform.

## Security Features

### 1. Group-Based Access
- Prefer Azure DevOps groups for access management.
- Avoid direct permissions for individual users when possible.

### 2. Membership Governance
- Add members through explicit, reviewable Terraform changes.
- Use `mode = "overwrite"` only with strict operational controls.

### 3. Auditability
- Changes are tracked through Terraform state and version control.
- Keep module inputs reviewed via pull requests.

## Security Configuration Example

```hcl
module "azuredevops_group" {
  source = "./modules/azuredevops_group"

  group_display_name = "ADO Security Reviewers"
  group_description  = "Security reviewers"

  group_memberships = [
    {
      key                = "security-membership"
      member_descriptors = ["vssgp.Uy0xLTktMTIzNDU2Nzg5MA"]
      mode               = "overwrite"
    }
  ]
}
```

## Security Hardening Checklist

- [ ] Manage access through groups, not individual users.
- [ ] Keep membership changes code-reviewed.
- [ ] Avoid broad overwrite operations unless required.
- [ ] Use dedicated module for entitlements and review license assignments separately.

## Additional Resources

- [Azure DevOps Security Documentation](https://learn.microsoft.com/en-us/azure/devops/organizations/security/about-security-identity?view=azure-devops)
- [Azure DevOps Permissions and Access Levels](https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions?view=azure-devops)

---

**Module Version**: 1.0.0  
**Last Updated**: 2026-02-13  
**Security Contact**: patryk.ciechanski@patrykiti.pl
