# Secure App Service Plan Example

This example demonstrates an operationally hardened App Service Plan baseline
with zonal worker placement and centralized diagnostics for container-hosting
scenarios.

## Features

- Creates a Premium v3 Windows Container App Service Plan
- Enables zone balancing with more than one worker
- Streams supported logs and metrics to Log Analytics
- Applies explicit production-oriented tags

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
