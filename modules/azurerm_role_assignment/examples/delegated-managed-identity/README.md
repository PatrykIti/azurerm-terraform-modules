# Delegated Managed Identity Example

This example demonstrates the `delegated_managed_identity_resource_id` input.

## Features

- Creates a principal managed identity and a delegated managed identity
- Assigns the Reader role at a resource group scope
- Passes the delegated managed identity resource ID to the module

## Notes

`delegated_managed_identity_resource_id` is intended for cross-tenant scenarios.
If you do not need delegated assignments, omit this input.

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
