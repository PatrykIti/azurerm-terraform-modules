# Complete Azure DevOps Agent Pools Example

This example demonstrates a fuller Azure DevOps Agent Pools configuration with non-default pool settings.

## Features

- Single module-managed agent pool with custom settings
- Fixed, deterministic naming with override variables

## Key Configuration

This configuration sets `pool_type = "deployment"` and custom provisioning behavior.

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
