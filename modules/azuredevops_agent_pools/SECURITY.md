# azuredevops_agent_pools Module Security

## Overview

This document describes security considerations for Azure DevOps agent pools managed by Terraform.

## Security Features

### 1. Agent Pools
- Use dedicated pools for sensitive workloads.
- Separate hosted and self-hosted pools by purpose.

## Security Configuration Example

```hcl
module "azuredevops_agent_pools" {
  source = "./modules/azuredevops_agent_pools"

  name           = "ado-secure-pool"
  auto_provision = false
  auto_update    = false
}
```

## Security Hardening Checklist

- [ ] Limit pool usage to approved projects.

## Common Security Mistakes to Avoid

1. **Sharing a single pool across high/low trust workloads**

## Additional Resources

- [Azure DevOps Agent Pools](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/pools-queues?view=azure-devops)
- [Azure DevOps Permissions and Access Levels](https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions?view=azure-devops)

---

**Module Version**: 1.0.0  
**Last Updated**: 2025-12-24  
**Security Contact**: patryk.ciechanski@patrykiti.pl
