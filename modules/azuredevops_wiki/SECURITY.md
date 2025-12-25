# azuredevops_wiki Module Security

## Overview

This document describes security considerations for Azure DevOps wikis managed with Terraform.

## Security Features

### 1. Content Hygiene
- Avoid storing secrets or tokens in wiki page content.
- Keep sensitive documentation in secure systems outside of wiki.

### 2. Access Control
- Use project permissions to control who can edit wikis.
- Limit contributor roles to trusted groups.

### 3. Repository-backed Wikis
- When using code wikis, apply repository protections and branch policies.

## Security Configuration Example

```hcl
module "azuredevops_wiki" {
  source = "./modules/azuredevops_wiki"

  project_id = "00000000-0000-0000-0000-000000000000"

  wikis = {
    project = {
      name = "Project Wiki"
      type = "projectWiki"
    }
  }

  wiki_pages = [
    {
      wiki_key = "project"
      path     = "/Home"
      content  = "Welcome to the project wiki."
    }
  ]
}
```

## Security Hardening Checklist

- [ ] Keep wiki content free of secrets.
- [ ] Restrict edit permissions to trusted teams.
- [ ] Apply repo protections for code wikis.

## Common Security Mistakes to Avoid

1. **Storing credentials directly in wiki pages**
2. **Allowing broad edit access to all users**
3. **Skipping reviews for wiki content updates**

## Additional Resources

- [Azure DevOps Wiki](https://learn.microsoft.com/en-us/azure/devops/project/wiki/wiki-create-repo)
- [Azure DevOps Permissions](https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions)

---

**Module Version**: 1.0.0  
**Last Updated**: 2025-12-24  
**Security Contact**: security@yourorganization.com
