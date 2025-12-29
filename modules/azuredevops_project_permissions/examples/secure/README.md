# Secure Azure DevOps Project Permissions Example

This example demonstrates least-privilege permission assignments for project-level groups.

## Features

- Grants only required read permissions.
- Avoids broad or write-level permissions.
- Uses group name lookup to keep descriptors out of configuration.

## Prerequisites

- An existing Azure DevOps project ID (`project_id`).
- Access to the target group name used in the example variables.

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
<!-- This section will be populated by terraform-docs if configured -->
<!-- END_TF_DOCS -->
