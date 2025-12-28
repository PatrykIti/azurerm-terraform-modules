# azuredevops_identity Module Security

## Overview

This document describes security considerations for managing Azure DevOps identities via Terraform. The module focuses on groups, entitlements, memberships, and security role assignments.

## Security Features

### 1. Group-Based Access
- Prefer Azure DevOps groups for access management.
- Avoid direct permissions for individual users when possible.

### 2. Entitlements and Licensing
- Grant only required license types.
- Use group entitlements to simplify access governance.

### 3. Role Assignments
- Assign minimal roles for a given scope.
- Separate admin and contributor responsibilities into distinct groups.

### 4. Auditability
- Changes are tracked through Terraform state and version control.
- Keep module inputs reviewed via code reviews.

## Security Configuration Example

```hcl
module "azuredevops_identity" {
  source = "./modules/azuredevops_identity"

  group_display_name = "ADO Platform Team"
  group_description  = "Platform engineering group"

  group_memberships = [
    {
      key                = "platform-membership"
      member_descriptors = ["vssgp.Uy0xLTktMTIzNDU2Nzg5MA"]
      mode               = "add"
    }
  ]

  user_entitlements = [
    {
      principal_name       = "user@example.com"
      account_license_type = "basic"
      licensing_source     = "account"
    }
  ]
}
```

## Security Hardening Checklist

- [ ] Manage access through groups, not individual users.
- [ ] Use least-privilege roles for scoped assignments.
- [ ] Review entitlements and licenses regularly.
- [ ] Restrict service principal entitlements to required scopes.
- [ ] Track changes through PR reviews and approvals.

## Common Security Mistakes to Avoid

1. **Granting high-privilege roles to large groups**
2. **Assigning licenses without access reviews**
3. **Mixing admin and contributor entitlements in the same group**
4. **Leaving stale service principals with active entitlements**

## Additional Resources

- [Azure DevOps Security Documentation](https://learn.microsoft.com/en-us/azure/devops/organizations/security/about-security-identity?view=azure-devops)
- [Azure DevOps Permissions and Access Levels](https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions?view=azure-devops)

---

**Module Version**: 1.0.0  
**Last Updated**: 2025-12-28  
**Security Contact**: security@yourorganization.com
