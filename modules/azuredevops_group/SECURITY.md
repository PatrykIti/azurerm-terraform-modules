# azuredevops_group Module Security

## Overview

This document describes security considerations for managing Azure DevOps groups via Terraform. The module focuses on groups, group entitlements, and memberships.

## Security Features

### 1. Group-Based Access
- Prefer Azure DevOps groups for access management.
- Avoid direct permissions for individual users when possible.

### 2. Entitlements and Licensing
- Grant only required license types.
- Use group entitlements to simplify access governance.

### 3. Auditability
- Changes are tracked through Terraform state and version control.
- Keep module inputs reviewed via code reviews.

## Security Configuration Example

```hcl
module "azuredevops_group" {
  source = "./modules/azuredevops_group"

  group_display_name = "ADO Platform Team"
  group_description  = "Platform engineering group"

  group_memberships = [
    {
      key                = "platform-membership"
      member_descriptors = ["vssgp.Uy0xLTktMTIzNDU2Nzg5MA"]
      mode               = "add"
    }
  ]

  group_entitlements = [
    {
      display_name         = "ADO Platform Team"
      account_license_type = "basic"
      licensing_source     = "account"
    }
  ]
}
```

## Security Hardening Checklist

- [ ] Manage access through groups, not individual users.
- [ ] Review entitlements and licenses regularly.
- [ ] Track changes through PR reviews and approvals.

## Common Security Mistakes to Avoid

1. **Granting high-privilege entitlements to large groups**
2. **Assigning licenses without access reviews**
3. **Mixing admin and contributor entitlements in the same group**

## Additional Resources

- [Azure DevOps Security Documentation](https://learn.microsoft.com/en-us/azure/devops/organizations/security/about-security-identity?view=azure-devops)
- [Azure DevOps Permissions and Access Levels](https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions?view=azure-devops)

---

**Module Version**: 1.0.0  
**Last Updated**: 2025-12-28  
**Security Contact**: patryk.ciechanski@patrykiti.pl
