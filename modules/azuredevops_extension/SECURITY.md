# azuredevops_extension Module Security

## Overview

This document describes security considerations for managing Azure DevOps Marketplace extensions with Terraform.

## Security Features

### 1. Extension Governance
- Install only vetted extensions from trusted publishers.
- Use an allowlist for approved extensions.

### 2. Version Control
- Pin extension versions to reduce supply-chain risk.
- Review release notes before upgrading.

### 3. Access Control
- Restrict PAT scopes to the minimum required for extension management.
- Limit who can install or update extensions in the organization.

## Security Configuration Example

```hcl
module "azuredevops_extension" {
  source = "./modules/azuredevops_extension"

  publisher_id      = "approved-publisher"
  extension_id      = "approved-extension"
  extension_version = "1.2.3"
}
```

## Security Hardening Checklist

- [ ] Maintain an allowlist of approved extensions.
- [ ] Pin versions for production environments.
- [ ] Review extension permissions and scopes.
- [ ] Audit extension inventory regularly.

## Common Security Mistakes to Avoid

1. **Installing unvetted extensions**
2. **Using broad PAT scopes for automation**
3. **Allowing unpinned version upgrades**

## Additional Resources

- [Azure DevOps Marketplace Extensions](https://learn.microsoft.com/en-us/azure/devops/marketplace/overview?view=azure-devops)
- [Azure DevOps Permissions and Access Levels](https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions?view=azure-devops)

---

**Module Version**: 1.0.0  
**Last Updated**: 2025-12-25  
**Security Contact**: patryk.ciechanski@patrykiti.pl
