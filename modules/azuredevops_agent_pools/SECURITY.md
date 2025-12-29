# azuredevops_agent_pools Module Security

## Overview

This document describes security considerations for Azure DevOps agent pools, queues, and elastic pools managed by Terraform.

## Security Features

### 1. Agent Pools
- Use dedicated pools for sensitive workloads.
- Separate hosted and self-hosted pools by purpose.

### 2. Agent Queues
- Queue access is project-scoped; keep access minimal.
- Avoid sharing queues across unrelated projects.

### 3. Elastic Pools
- Restrict service endpoints to least privilege.
- Limit max capacity to avoid unexpected spend.

## Security Configuration Example

```hcl
module "azuredevops_agent_pools" {
  source = "./modules/azuredevops_agent_pools"

  name           = "ado-secure-pool"
  auto_provision = false
  auto_update    = false

  agent_queues = [
    {
      key        = "secure"
      project_id = "00000000-0000-0000-0000-000000000000"
    }
  ]
}
```

## Security Hardening Checklist

- [ ] Limit pool usage to approved projects.
- [ ] Use least-privilege service endpoints for elastic pools.
- [ ] Cap elastic pool max capacity.
- [ ] Review queue access regularly.

## Common Security Mistakes to Avoid

1. **Sharing a single pool across high/low trust workloads**
2. **Granting wide access to project queues**
3. **Allowing elastic pools to scale without limits**

## Additional Resources

- [Azure DevOps Agent Pools](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/pools-queues?view=azure-devops)
- [Azure DevOps Permissions and Access Levels](https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions?view=azure-devops)

---

**Module Version**: 1.0.0  
**Last Updated**: 2025-12-24  
**Security Contact**: security@yourorganization.com
