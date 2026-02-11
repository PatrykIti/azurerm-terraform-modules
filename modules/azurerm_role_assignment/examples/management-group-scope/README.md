# Management Group Scope Example

This example assigns the built-in Reader role at a management group scope.

## Features

- Uses a management group scope for the assignment
- Creates a user-assigned managed identity to receive the role
- Demonstrates cross-scope usage outside resource groups

## Notes

- Provide an existing management group ID via `management_group_id`.
- You need permissions to create role assignments at the management group scope.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Cleanup

```bash
terraform destroy
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
