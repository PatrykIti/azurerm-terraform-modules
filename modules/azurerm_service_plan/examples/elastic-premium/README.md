# Elastic Premium App Service Plan Example

This example demonstrates an Elastic Premium Linux App Service Plan with
autoscale support and a configured elastic worker ceiling.

## Features

- Creates an EP1 Linux App Service Plan
- Enables Premium autoscale support
- Sets `maximum_elastic_worker_count` for elastic growth

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
