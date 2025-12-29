# Complete Azure DevOps Agent Pools Example

This example demonstrates a fuller Azure DevOps Agent Pools configuration with queues and an optional elastic pool.

## Features

- Single module-managed agent pool with custom settings
- Multiple queues (module pool + external pool)
- Optional elastic pool configuration (requires service endpoint, scope, and Azure resource ID)
- Random suffixes to avoid naming conflicts

## Key Configuration

Set `enable_elastic_pool` to `true` and provide `service_endpoint_id`, `service_endpoint_scope`, and `azure_resource_id`.

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
