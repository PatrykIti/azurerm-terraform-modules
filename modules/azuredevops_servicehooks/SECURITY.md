# azuredevops_servicehooks Module Security

## Overview

This document describes security considerations for Azure DevOps webhook service hooks managed with Terraform.

## Security Features

### 1. Webhook Protection
- Use HTTPS endpoints and validate certificates.
- Limit webhook scope using event filters and repository/project constraints.

### 2. Credential Handling
- Avoid storing basic auth secrets directly in code.
- Use external secret managers or environment variables for sensitive values.

### 3. Event Scope Hardening
- Prefer specific events and filters instead of broad subscriptions.
- Keep webhook endpoints isolated per integration where feasible.

## Security Configuration Example

```hcl
module "azuredevops_servicehooks" {
  source = "./modules/azuredevops_servicehooks"

  project_id = "00000000-0000-0000-0000-000000000000"

  webhook = {
    url = "https://example.com/webhook"
    git_push = {
      branch = "refs/heads/main"
    }
  }
}
```

## Security Hardening Checklist

- [ ] Use HTTPS endpoints and verify certificate trust.
- [ ] Limit event scope with branch/repository filters.
- [ ] Store webhook credentials outside of Terraform state.
- [ ] Keep webhook subscriptions least-privilege and narrowly scoped.

## Common Security Mistakes to Avoid

1. **Using HTTP endpoints without TLS**
2. **Publishing all events without filters**
3. **Embedding webhook credentials directly in code**

## Additional Resources

- [Azure DevOps Service Hooks](https://learn.microsoft.com/en-us/azure/devops/service-hooks/services/webhooks)
- [Azure DevOps Permissions](https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions)

---

**Module Version**: 1.0.0  
**Last Updated**: 2026-02-14  
**Security Contact**: patryk.ciechanski@patrykiti.pl
