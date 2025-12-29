# azuredevops_environments Module Security

## Overview

This document describes security considerations for Azure DevOps environments and checks managed with Terraform.

## Security Features

### 1. Environment Checks
- Require approvals before deployments.
- Enforce branch control and business hours to restrict release windows.

### 2. Exclusive Locks
- Use exclusive lock checks to prevent concurrent deployments.

### 3. Required Templates
- Enforce pipeline templates to standardize deployments.

## Security Configuration Example

```hcl
module "azuredevops_environments" {
  source = "./modules/azuredevops_environments"

  project_id  = "00000000-0000-0000-0000-000000000000"
  name        = "ado-env-prod"
  description = "Production environment"

  check_approvals = [
    {
      key                  = "prod-approval"
      target_resource_type = "environment"
      approvers            = ["00000000-0000-0000-0000-000000000000"]
      requester_can_approve = false
    }
  ]
}
```

## Security Hardening Checklist

- [ ] Require approvals for production environments.
- [ ] Use exclusive locks to prevent parallel deployments.
- [ ] Restrict deployments to approved branches.
- [ ] Define business hours for sensitive environments.

## Common Security Mistakes to Avoid

1. **Skipping approvals for production environments**
2. **Allowing deployments outside approved hours**
3. **Leaving environments without explicit checks**

## Additional Resources

- [Approvals and Checks](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/approvals?view=azure-devops)
- [Environments](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops)

---

**Module Version**: 1.0.0  
**Last Updated**: 2025-12-24  
**Security Contact**: patryk.ciechanski@patrykiti.pl
