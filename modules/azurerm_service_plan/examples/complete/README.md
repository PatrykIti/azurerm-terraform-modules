# Complete App Service Plan Example

This example demonstrates a Premium Linux App Service Plan with explicit worker
count, per-site scaling, zone balancing, and inline diagnostic settings.

## Features

- Creates a Premium v3 Linux App Service Plan
- Enables per-site scaling and zonal balancing
- Streams supported logs and metrics to Log Analytics
- Applies production-style metadata tags

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
