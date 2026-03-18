# azuredevops_elastic_pool Module Security

## Overview

This document describes security considerations for Azure DevOps elastic pools managed by Terraform.

## Security Features

### 1. Elastic Pool Scope
- Module manages only `azuredevops_elastic_pool` and avoids cross-scope resources.
- Consumer configuration remains responsible for broader project-level policy composition.

### 2. Endpoint and Capacity Controls
- Use least-privilege service endpoints dedicated to elastic pool operations.
- Keep `max_capacity` constrained to expected workload limits to reduce risk and spend.
- Consider `recycle_after_each_use = true` for stronger workload isolation.

## Security Configuration Example

```hcl
module "azuredevops_elastic_pool" {
  source = "./modules/azuredevops_elastic_pool"

  name                   = "ado-secure-elastic-pool"
  service_endpoint_id    = var.service_endpoint_id
  service_endpoint_scope = var.service_endpoint_scope
  azure_resource_id      = var.azure_resource_id

  desired_idle           = 0
  max_capacity           = 2
  recycle_after_each_use = true
  auto_provision         = false
  auto_update            = false
}
```

## Security Hardening Checklist

- [ ] Restrict service endpoint permissions to least privilege.
- [ ] Use conservative `max_capacity` and `desired_idle` values.
- [ ] Enable `recycle_after_each_use` where stronger isolation is needed.
- [ ] Keep `auto_provision` and `auto_update` disabled unless explicitly required.

## Common Security Mistakes to Avoid

1. **Using over-privileged service endpoints shared across unrelated workloads**
2. **Allowing unconstrained elastic scaling in sensitive organizations**
3. **Enabling automation defaults without explicit operational review**

## Additional Resources

- [Azure DevOps Elastic Pool](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/pools-queues?view=azure-devops)
- [Azure DevOps Permissions and Access Levels](https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions?view=azure-devops)

---

**Module Version**: 1.0.0  
**Last Updated**: 2026-02-13  
**Security Contact**: patryk.ciechanski@patrykiti.pl
