# Complete Azure DevOps Identity Example

This example demonstrates groups, memberships, and optional entitlements.

## Features

- Creates multiple Azure DevOps groups
- Adds group-to-group memberships
- Supports optional entitlements for users, groups, and service principals
- Includes an optional security role assignment example with a stable key

## Key Configuration

Provide optional entitlement variables and set `security_role_assignment_resource_id` to enable the sample role assignment.

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
