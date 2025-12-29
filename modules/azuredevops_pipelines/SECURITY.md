# azuredevops_pipelines Module Security

## Overview

This document describes security considerations for Azure DevOps pipelines managed with Terraform.

## Security Features

### 1. Pipeline Permissions
- Grant build definition permissions only to approved groups.
- Limit queue and edit permissions to reduce unintended changes.

### 2. Pipeline Authorizations
- Explicitly authorize pipelines to use service connections, queues, and variable groups.
- Prefer per-pipeline authorizations over "all pipelines" access.

### 3. Secret Management
- Keep secrets in variable groups or secure files; avoid inline secret values.
- Mark secret variables as `is_secret` when required by the pipeline.

## Security Configuration Example

```hcl
module "azuredevops_pipelines" {
  source = "./modules/azuredevops_pipelines"

  project_id = "00000000-0000-0000-0000-000000000000"

  name = "secure-pipeline"

  repository = {
    repo_type = "TfsGit"
    repo_id   = "00000000-0000-0000-0000-000000000000"
    yml_path  = "azure-pipelines.yml"
  }

  pipeline_authorizations = [
    {
      resource_id = "00000000-0000-0000-0000-000000000000"
      type        = "endpoint"
    }
  ]
}
```

## Security Hardening Checklist

- [ ] Restrict build definition permissions to groups.
- [ ] Keep service connections scoped to required pipelines only.
- [ ] Use variable groups for secrets and protect them with checks.
- [ ] Review pipeline authorizations regularly.

## Common Security Mistakes to Avoid

1. **Allowing all pipelines to access privileged service connections**
2. **Granting edit permissions to broad groups**
3. **Storing secrets directly in pipeline variables**

## Additional Resources

- [Pipeline Permissions](https://learn.microsoft.com/en-us/azure/devops/pipelines/policies/permissions?view=azure-devops)
- [Approvals and Checks](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/approvals?view=azure-devops)

---

**Module Version**: 1.0.0  
**Last Updated**: 2025-12-28  
**Security Contact**: patryk.ciechanski@patrykiti.pl
