# Complete Azure DevOps Agent Pools Example

This example demonstrates a fuller Azure DevOps Agent Pools configuration with multiple pools, queues, and an optional elastic pool.

## Features

- Multiple agent pools with distinct settings
- Multiple queues attached to the same project
- Optional elastic pool configuration (requires service endpoint and Azure resource ID)
- Random suffixes to avoid naming conflicts

## Key Configuration

Set `enable_elastic_pool` to `true` and provide `service_endpoint_id` plus `azure_resource_id` to create an elastic pool.

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
