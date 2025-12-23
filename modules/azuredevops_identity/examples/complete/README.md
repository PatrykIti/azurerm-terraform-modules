# Complete Azure DevOps Identity Example

This example demonstrates groups, memberships, and optional entitlements.

## Features

- Creates multiple Azure DevOps groups
- Adds group-to-group memberships
- Supports optional entitlements for users, groups, and service principals
- Accepts optional security role assignments via variables

## Key Configuration

Provide optional entitlement and role assignment variables to enable additional access management.

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```
2. Review and apply:
   ```bash
   terraform plan
   terraform apply
   ```

## Cleanup

```bash
terraform destroy
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
