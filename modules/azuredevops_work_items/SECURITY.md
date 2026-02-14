# azuredevops_work_items Module Security

## Overview

This document describes security considerations for managing Azure DevOps work items with Terraform.

## Security Guidance

### 1. Limit Scope of Changes
- Manage only required fields on each work item.
- Avoid storing sensitive data in work item fields unless policy explicitly allows it.

### 2. Validate Input Data
- Keep `project_id`, `title`, and `type` controlled and non-empty.
- Validate `custom_fields` values to avoid accidental injection of empty or malformed values.

### 3. Protect Access to Terraform Credentials
- Restrict PAT/API credentials used by Terraform to least privilege.
- Use short-lived credentials and rotate them regularly.

## Security Configuration Example

```hcl
module "azuredevops_work_items" {
  source = "./modules/azuredevops_work_items"

  project_id = "00000000-0000-0000-0000-000000000000"
  title      = "Secure Work Item"
  type       = "Issue"

  tags = ["terraform", "security-reviewed"]

  custom_fields = {
    "System.Description" = "Managed via Terraform"
  }
}
```

## Security Hardening Checklist

- [ ] Restrict module usage to trusted CI identities.
- [ ] Review work item data for sensitive content before apply.
- [ ] Validate custom fields and metadata in code review.

## Common Security Mistakes to Avoid

1. **Embedding secrets in work item fields**
2. **Using over-privileged PAT scopes for Terraform runs**
3. **Allowing unreviewed custom field writes from untrusted input**

## Additional Resources

- [Azure DevOps Work Items](https://learn.microsoft.com/en-us/azure/devops/boards/work-items/about-work-items)
- [Azure DevOps Security](https://learn.microsoft.com/en-us/azure/devops/organizations/security/about-security-identity)

---

**Module Version**: 1.0.0  
**Last Updated**: 2026-02-14  
**Security Contact**: patryk.ciechanski@patrykiti.pl
