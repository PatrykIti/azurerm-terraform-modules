# azuredevops_environments Module Security

## Overview

This document describes security considerations for Azure DevOps Git repositories managed with Terraform.

## Security Features

### 1. Branch Protections
- Require minimum reviewers and status checks on protected branches.
- Enforce work item linking and comment resolution.

### 2. Repository Policies
- Enforce author email patterns and reserved names.
- Limit file size and path length to reduce risk.

### 3. Permissions
- Use least privilege for repository and branch permissions.
- Assign permissions to groups rather than individual users.

## Security Configuration Example

```hcl
module "azuredevops_environments" {
  source = "./modules/azuredevops_environments"

  project_id = "00000000-0000-0000-0000-000000000000"

  repositories = {
    main = {
      name = "secure-repo"
      initialization = {
        init_type = "Clean"
      }
    }
  }

  branch_policy_min_reviewers = [
    {
      reviewer_count = 2
      scope = [
        {
          repository_key = "main"
          match_type     = "DefaultBranch"
        }
      ]
    }
  ]

  branch_policy_status_check = [
    {
      name = "security-check"
      scope = [
        {
          repository_key = "main"
          match_type     = "DefaultBranch"
        }
      ]
    }
  ]

  repository_policy_check_credentials = [
    {
      repository_keys = ["main"]
    }
  ]
}
```

## Security Hardening Checklist

- [ ] Protect default branches with reviewers and status checks.
- [ ] Restrict repository permissions to approved groups.
- [ ] Enable repository policies for credentials and path controls.
- [ ] Regularly audit repository policy compliance.

## Common Security Mistakes to Avoid

1. **Allowing direct pushes to protected branches**
2. **Granting broad permissions to individual users**
3. **Skipping build validation or status checks**

## Additional Resources

- [Azure DevOps Branch Policies](https://learn.microsoft.com/en-us/azure/devops/repos/git/branch-policies?view=azure-devops)
- [Azure DevOps Permissions and Access Levels](https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions?view=azure-devops)

---

**Module Version**: 1.0.0  
**Last Updated**: 2025-12-24  
**Security Contact**: security@yourorganization.com
