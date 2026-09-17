# Complete App Service Plan Example

This example demonstrates a Standard Linux App Service Plan with explicit
worker count, per-site scaling, and inline diagnostic settings.

## Features

- Creates a Standard Linux App Service Plan
- Enables per-site scaling with explicit worker capacity
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
