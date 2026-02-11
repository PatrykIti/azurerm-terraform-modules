# Complete Role Assignment Example

This example demonstrates a role assignment with explicit name, principal type, description, and ABAC condition.

## Features

- Uses a fixed role assignment GUID
- Includes `principal_type`, `description`, and `skip_service_principal_aad_check`
- Adds an ABAC `condition` with `condition_version = "2.0"`
- Assigns a built-in data role at storage account scope

## Key Configuration

This example focuses on advanced RBAC inputs without introducing unrelated networking or monitoring glue.

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
