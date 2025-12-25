# azuredevops_project Module Security

## Overview

This document describes security considerations for the Azure DevOps project module. The module focuses on project-level controls: visibility, pipeline settings, feature enablement, and dashboards.

## Security Features

### 1. Project Visibility
- Default visibility is **private**.
- Public projects should be used only when explicitly required.

### 2. Pipeline Settings
- Enforce job scope to the current project.
- Limit repository-scoped tokens in YAML pipelines.
- Limit variables that can be set at queue time.
- Keep status badges private.

### 3. Feature Management
- Disable unused features (e.g., artifacts, test plans) to reduce the attack surface.

### 4. Permissions (separate module)
- Project permissions are managed via the `azuredevops_project_permissions` module.
- Assign permissions to groups, not individual users, and apply least privilege.

## Security Configuration Example

```hcl
module "azuredevops_project" {
  source = "./modules/azuredevops_project"

  name               = "ado-project-secure"
  description        = "Secure project managed by Terraform"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"

  features = {
    boards       = "enabled"
    repositories = "enabled"
    pipelines    = "enabled"
    testplans    = "disabled"
    artifacts    = "disabled"
  }

  pipeline_settings = {
    enforce_job_scope                    = true
    enforce_referenced_repo_scoped_token = true
    enforce_settable_var                 = true
    publish_pipeline_metadata            = false
    status_badges_are_private            = true
    enforce_job_scope_for_release        = true
  }
}
```

The `examples/secure` configuration is the reference hardened setup for this module.

## Security Hardening Checklist

- [ ] Keep project visibility set to private.
- [ ] Disable unused project features.
- [ ] Enforce job scope and restrict pipeline tokens.
- [ ] Keep status badges private.
- [ ] Assign permissions to groups (via the permissions module) and review them regularly.

## Common Security Mistakes to Avoid

1. **Public project visibility without review**
2. **Leaving pipeline metadata publicly accessible**
3. **Granting broad project permissions to large groups**
4. **Enabling unused features without governance**

## Additional Resources

- [Azure DevOps Security Documentation](https://learn.microsoft.com/en-us/azure/devops/organizations/security/about-security-identity?view=azure-devops)
- [Pipeline Security Best Practices](https://learn.microsoft.com/en-us/azure/devops/pipelines/security/overview?view=azure-devops)

---

**Module Version**: 1.0.0  
**Last Updated**: 2025-12-23  
**Security Contact**: security@yourorganization.com
