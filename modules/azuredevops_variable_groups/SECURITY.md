# azuredevops_variable_groups Module Security

## Overview

This document describes security considerations for Azure DevOps variable groups managed with Terraform.

## Security Features

### 1. Secret Handling
- Mark sensitive variables with `is_secret` and provide `secret_value`.
- Use Key Vault-backed variable groups for centralized secret storage.

### 2. Access Control
- Restrict variable group permissions to trusted groups.
- Avoid granting `Administer` or `Owner` unless required.

### 3. Pipeline Access
- Use `allow_access` sparingly to avoid exposing secrets to all pipelines.

## Security Configuration Example

```hcl
module "azuredevops_variable_groups" {
  source = "./modules/azuredevops_variable_groups"

  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "secure-vars"

  description  = "Secrets for production"
  allow_access = false

  variables = [
    {
      name         = "api_key"
      secret_value = "example-secret"
      is_secret    = true
    }
  ]

  variable_group_permissions = [
    {
      principal = "vssgp.Uy0xLTktMTIzNDU2"
      permissions = {
        View       = "allow"
        Use        = "allow"
        Administer = "deny"
      }
    }
  ]
}
```

## Security Hardening Checklist

- [ ] Store secrets in Key Vault or mark them as secret values.
- [ ] Keep `allow_access` disabled unless required for all pipelines.
- [ ] Grant variable group permissions to groups, not individual users.
- [ ] Review permissions for `Administer` and `Owner` regularly.

## Common Security Mistakes to Avoid

1. **Storing secret values as plain variables**
2. **Allowing access to all pipelines without review**
3. **Assigning admin permissions to broad groups**

## Additional Resources

- [Azure DevOps Variable Groups](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups)
- [Azure DevOps Permissions](https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions)

---

**Module Version**: 1.0.0  
**Last Updated**: 2025-12-25  
**Security Contact**: patryk.ciechanski@patrykiti.pl
