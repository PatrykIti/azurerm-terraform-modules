# azuredevops_serviceendpoint Module Security

## Overview

This document describes security considerations for Azure DevOps service connections managed with Terraform.

## Security Features

### 1. Scoped Service Connections
- Use the minimal set of service endpoints required for pipelines.
- Prefer dedicated endpoints per workload or environment.

### 2. Permissions
- Assign service endpoint permissions to groups, not individual users.
- Use `serviceendpoint_permissions` to limit who can use or administer connections.

### 3. Secret Handling
- Store secrets in secure variables or secret stores.
- Avoid hardcoding credentials in source control.

## Security Configuration Example

```hcl
module "azuredevops_serviceendpoint" {
  source = "./modules/azuredevops_serviceendpoint"

  project_id = "00000000-0000-0000-0000-000000000000"

  serviceendpoint_generic = {
    service_endpoint_name = "example-generic"
    server_url            = "https://example.endpoint.local"
    username              = "example-user"
    password              = "example-password"
  }

  serviceendpoint_permissions = [
    {
      principal   = "00000000-0000-0000-0000-000000000000"
      permissions = {
        Use        = "Allow"
        Administer = "Deny"
      }
    }
  ]
}
```

## Security Hardening Checklist

- [ ] Limit service connections to required scopes only.
- [ ] Use group-based permissions for service endpoints.
- [ ] Rotate credentials regularly and revoke unused endpoints.

## Common Security Mistakes to Avoid

1. **Sharing a single service connection across unrelated teams**
2. **Granting Administer permissions broadly**
3. **Embedding secrets directly in Terraform state**

## Additional Resources

- [Service Connections](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints)
- [Azure DevOps Permissions](https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions)

---

**Module Version**: 1.0.0  
**Last Updated**: 2025-12-28  
**Security Contact**: security@yourorganization.com
