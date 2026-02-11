# azurerm_user_assigned_identity Module Security

## Overview

This module provisions a User Assigned Identity (UAI) and optional federated identity
credentials (FICs). Security posture depends primarily on:

- **Trust boundaries** encoded in `issuer`, `subject`, and `audience` for each FIC.
- **Least privilege** RBAC applied outside the module.
- **Clear ownership** and tagging of identities.

## Security Features

### 1. **Federated Identity Credentials (OIDC Trust)**

- **Explicit creation only**: FICs are created only when provided via input.
- **Issuer validation**: only HTTPS issuers are accepted by module validation.
- **Subject and audience checks**: non-empty subject and audience values are enforced.

Misconfigured FICs can allow unintended workloads to obtain tokens for your identity.
Treat `issuer`, `subject`, and `audience` as security boundaries.

### 2. **Access Control**

- **No RBAC by default**: the module does not assign roles.
- Apply **least-privilege** role assignments externally based on workload needs.
- Prefer resource-group or resource-scoped roles instead of subscription-wide scopes.

### 3. **Operational Hygiene**

- Use tags to identify owners, environments, and cost centers.
- Review identities periodically and remove unused FICs.
- Keep identities scoped to specific workloads and environments.

## Secure Configuration Example

```hcl
module "user_assigned_identity" {
  source = "./modules/azurerm_user_assigned_identity"

  name                = "uai-secure-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  federated_identity_credentials = [
    {
      name     = "github-actions"
      issuer   = "https://token.actions.githubusercontent.com"
      subject  = "repo:example-org/example-repo:ref:refs/heads/main"
      audience = ["api://AzureADTokenExchange"]
    }
  ]

  tags = {
    Environment = "Production"
    Owner       = "platform-team"
  }
}

resource "azurerm_role_assignment" "rg_reader" {
  scope                = azurerm_resource_group.example.id
  role_definition_name = "Reader"
  principal_id         = module.user_assigned_identity.principal_id
}
```

## Security Hardening Checklist

Before deploying to production:

- [ ] FIC `issuer` matches the expected OIDC provider domain.
- [ ] FIC `subject` is scoped to a specific repo/environment/workload.
- [ ] FIC `audience` matches Azure token exchange expectations.
- [ ] RBAC is least-privilege and scoped to required resources only.
- [ ] Identity ownership and lifecycle are documented.
- [ ] Tags include environment and owner information.

## Common Security Mistakes to Avoid

1. **Overly broad subjects**
   ```hcl
   # ❌ Avoid broad or wildcard-like subjects
   subject = "repo:example-org/*"
   ```

2. **Using untrusted issuers**
   ```hcl
   # ❌ Avoid non-HTTPS or unexpected issuers
   issuer = "http://example.com"
   ```

3. **Granting excessive RBAC scopes**
   ```hcl
   # ❌ Avoid assigning Owner or Contributor at subscription scope
   scope                = data.azurerm_subscription.primary.id
   role_definition_name = "Owner"
   ```

## Incident Response

If a token is abused or credentials are suspected to be compromised:

1. Remove or rotate affected federated identity credentials.
2. Review RBAC assignments and reduce scope.
3. Audit sign-in logs and Azure activity logs for suspicious usage.
4. Re-issue credentials with narrower subject/audience scopes.

---

**Module Version**: vUnreleased  
**Last Updated**: 2026-01-30
