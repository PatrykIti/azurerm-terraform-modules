# Secure Azure DevOps Agent Pools Example

This example demonstrates a security-focused Azure DevOps Agent Pools configuration with minimal automation.

## Features

- Agent pool with `auto_provision` and `auto_update` disabled
- Single queue scoped to a project, using the module pool
- Random suffixes to avoid naming conflicts

## Key Configuration

Use this example when you want tighter control over pool provisioning and updates.

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
