# Secure Role Assignment Example

This example demonstrates a least-privilege role assignment using a custom role definition scoped to a single resource group.

## Features

- Creates a custom role definition limited to the resource group
- Assigns the custom role to a user-assigned managed identity
- Demonstrates least-privilege RBAC with minimal actions

## Key Configuration

This example emphasizes least-privilege by combining a narrow scope and a minimal permissions list.

## Security Considerations

- Limit scope to the smallest practical resource group
- Avoid built-in Owner/Contributor roles when possible

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
