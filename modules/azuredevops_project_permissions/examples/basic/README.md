# Basic Azure DevOps Project Permissions Example

This example assigns a minimal permission set to a collection-level group by name.

## Features

- Assigns a single permission to a collection group.
- Uses group name lookup instead of hardcoded descriptors.

## Prerequisites

- An existing Azure DevOps project ID (`project_id`).
- Access to the collection group name (defaults to `Project Collection Administrators`).

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
